import vibe.vibe;
import vibe.core.log;

import core.thread;
import core.time;
import std.stdio;
import std.regex;
import std.json;
import std.parallelism;
import std.concurrency;
import std.algorithm;
import std.uri;
import std.net.curl;
import std.file: thisExePath, chdir;
import std.path: dirName;
import std.format;
import core.stdc.stdlib: exit;

import twitter4d;

import settings;

class ReconnectedCountMaxException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

void safeWrite(string text)
{
	synchronized {
		logInfo(text);
	}
}

class Twitter {
	private Twitter4D t4d;
	private string consumerKey;
	private string consumerSecret;
	private string accessToken;
	private string accessTokenSecret;

	private auto pattern = ctRegex!`救援ID:([0-9]{10})\s参戦者募集！\s\s難易度:([A-Z]*)\s(.*)降臨！`;
	//private auto pattern = ctRegex!`([0-9A-F]{8})\s:参戦ID\s参加者募集！\sLv([0-9]*)\s(.*)`;

	private bool readTweetTerminateFlag = false;
	private string url = "https://stream.twitter.com/1.1/statuses/filter.json";
	private string[string] params;

	this(string CK, string CS, string AT, string AS) {
		consumerKey = CK;
		consumerSecret = CS;
		accessToken = AT;
		accessTokenSecret = AS;

		params = ["track":"参戦者募集！"];
		//params = ["track":"参加者募集！"];
	}
	
	// 文字列から救援IDを抽出
	private JSONValue parseText(JSONValue json)
	{
		typeof(return) result;
		auto m = matchFirst(json["text"].str, pattern);

		result["id"] = m[1];
		result["level"] = m[2];
		result["name"] = m[3];

		return result;
	}

	SysTime lastReceivedTime;
	void startStream()
	{
		lastReceivedTime = Clock.currTime;
		uint reconnectedCount = 0;
		JSONValue messageJson = [ "serverMessage": JSONValue(""), "count": JSONValue(0) ];

		//runTask((){watchStream();});

		safeWrite("start tweet reading ...");
		while (!readTweetTerminateFlag) {

			if (reconnectedCount >= 25) {
				messageJson["serverMessage"] = JSONValue("reload");
				wsController.sendAll(messageJson.toString);
				//throw new ReconnectedCountMaxException("再接続回数が25回に達しました。");
				exit(0);
			} else if (reconnectedCount > 0) {
				safeWrite("reconnectedCount: %s".format(reconnectedCount));

				messageJson["serverMessage"] = JSONValue("reconnect");
				messageJson["count"] = JSONValue(reconnectedCount);
				wsController.sendAll(messageJson.toString);

				auto waitMSec = msecs(250 * reconnectedCount);
				safeWrite("  waitMSec: %s".format(waitMSec));
				sleep(waitMSec);
			}

			try
			{
				t4d = new Twitter4D([
					"consumerKey": consumerKey,
					"consumerSecret": consumerSecret,
					"accessToken": accessToken,
					"accessTokenSecret": accessTokenSecret
				]);

				foreach(line; t4d.stream(url, params))
				{
					if(readTweetTerminateFlag) { break;	}
					lastReceivedTime = Clock.currTime;

					//safeWrite("stream readed...");
					auto s = line.to!string;
					if(match(s, regex(r"\{.*\}"))){
						auto j = parseJSON(s);

						if ("media" in j["entities"]) { continue; }

						j = parseText(j);
						wsController.sendAll(j.toString);
					}
				}
			} catch (PriorityMessageException e) {
				safeWrite("-----PriorityMessageException-----");
				safeWrite("Twitter Streaming filter API connection closed.");
				safeWrite("try reconnect...");
				safeWrite("----------------------------------");
				//safeWrite(e);
				//一度 CurlExceptionを吐かれると、thisTid.mboxに例外情報が残ったままに
				//なるっぽくて、それを取り除いてやらない限り同一プロセス上での
				//再接続は永遠に出来ないと思われる。
				auto ce = receiveOnly!(immutable(CurlException));
				//safeWrite(ce);
				
				reconnectedCount += 1;
			} finally {
				//pass
			}
		}

		safeWrite("stop tweet reading.");
	}

	void stopStream()
	{
		readTweetTerminateFlag = true;
	}

	void watchStream()
	{
		safeWrite("start watchStream()");
		while (!readTweetTerminateFlag) {
			auto ct = Clock.currTime;
			safeWrite((ct - lastReceivedTime).to!string);
			sleep(dur!"seconds"(1));
		}
		safeWrite("stop watchStream()");
	}
}

class WebSocketController
{
	WebSocketWrapper [] wrappers;

	class WebSocketWrapper
	{
		private WebSocket socket;
		alias socket this;

		bool waitTerminate = false;
		SysTime lastSendTime;

		this(WebSocket s)
		{
			socket = s;
			lastSendTime = Clock.currTime;
		}

		void eventLoop()
		{
			while (socket.waitForData)
			{
				if (waitTerminate) { break; }

				auto received = socket.receiveText;
				safeWrite(received);
			}
			safeWrite("eventLoop exit");
		}
	}

	void add(scope WebSocket socket)
	{
		auto wrapper = new WebSocketWrapper(socket);
		wrappers ~= wrapper;
		wrapper.eventLoop();
	}

	void sendAll(string text)
	{
		safeWrite(text);
		foreach(s; wrappers)
		{
			if (!s.connected) { continue; }
			s.send(text);
			s.lastSendTime = Clock.currTime;
		}
	}

	private bool keepAliveEnable = true;
	void stopKeepAlive()
	{
		keepAliveEnable = false;
		foreach(s; wrappers)
		{
			s.waitTerminate = true;
			s.close();
		}
	}

	void runKeepAlive()
	{
		JSONValue j = [ "keepAlive": true ];

		while (keepAliveEnable)
		{
			foreach(s; wrappers)
			{
				if (!s.connected) { continue; }

				if ((Clock.currTime - s.lastSendTime) < dur!"seconds"(10)) { continue; }

				s.send(j.toString);
				s.lastSendTime = Clock.currTime;
			}
			sleep(seconds(1));
		}
	}
}

WebSocketController wsController;

void main()
{
	auto twitter = new Twitter(
		twitterSettings.consumerKey,
		twitterSettings.consumerSecret,
		twitterSettings.accessToken,
		twitterSettings.accessTokenSecret
	);
	auto t = runTask(()=>twitter.startStream());
	scope(exit)
	{
		twitter.stopStream();
		t.join();
	}

	wsController = new WebSocketController;
	auto kaTid = runTask(()=>wsController.runKeepAlive());
	scope(exit)
	{
		wsController.stopKeepAlive();
		kaTid.join();
	}

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	settings.sessionStore = new MemorySessionStore;

	debug {
		settings.tlsContext = createTLSContext(TLSContextKind.server);
		settings.tlsContext.useCertificateChainFile("./config/server.crt");
		settings.tlsContext.usePrivateKeyFile("./config/server.key");
	}

	auto router = new URLRouter;
	router.registerWebInterface(new WebService);
	router.get("*", serveStaticFiles("public/"));
	router.get("/ws", handleWebSockets((a)=>wsController.add(a)));

	auto listener = listenHTTP(settings, router);
	scope(exit) {
		listener.stopListening();
	}

	string exePath = dirName(thisExePath());
	chdir(exePath);
	//auto logger = cast(shared)new FileLogger(exePath ~ "/access.log");
	//setLogLevel(LogLevel.warn);
	//registerLogger(logger);

	logInfo("application started.");
	runApplication();
}

class WebService
{

	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
		res.render!("index.dt");
	}

}
