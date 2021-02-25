import vibe.vibe;
import twitter4d;
import std.stdio;
import std.regex;
import std.json;
import std.parallelism;
import std.concurrency;
import std.algorithm;
import std.uri;
import std.net.curl;
import core.thread;
import settings;

void safeWrite(string text)
{
	synchronized {
		writeln(text);
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
		runTask((){watchStream();});
		writeln("start tweet reading ...");

		uint reconnectedCount = 0;
		uint waitSeconds = 0;

		while (!readTweetTerminateFlag) {
			try
			{
				writefln("reconnectedCount: %s", reconnectedCount);

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

					writeln("stream readed...");
					auto s = line.to!string;
					if(match(s, regex(r"\{.*\}"))){
						auto j = parseJSON(s);

						if ("media" in j["entities"]) { continue; }

						j = parseText(j);
						wsSend(j.toString);
					}
				}
			} catch (PriorityMessageException e) {
				writeln(e.message);
				t4d.destroy();
			} finally {
				if (reconnectedCount == 0) {
					waitSeconds = 5;
				} else {
					sleep(dur!"seconds"(waitSeconds));
					waitSeconds *= 2;
				}
				reconnectedCount += 1;
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
		writeln("start watchStream()");
		while (!readTweetTerminateFlag) {
			auto ct = Clock.currTime;
			writeln(ct - lastReceivedTime);
			sleep(dur!"seconds"(1));
		}
		writeln("stop watchStream()");
	}
}

WebSocketWrapper [] wrappers;

class WebSocketWrapper
{
	private WebSocket socket;
	alias socket this;

	bool waitTerminate = false;

	this(WebSocket s)
	{
		socket = s;
	}

	void eventLoop()
	{
		while (socket.waitForData)
		{
			if (waitTerminate) { break; }

			auto received = socket.receiveText;
			safeWrite(received);
		}
		writeln("eventLoop exit");
	}
}

void wsHandler(scope WebSocket socket)
{
	auto wrapper = new WebSocketWrapper(socket);
	wrappers ~= wrapper;
	wrapper.eventLoop();
}

void wsSend(string text)
{
	safeWrite(text);
	foreach(s; wrappers)
	{
		if (!s.connected) { continue; }
		s.send(text);
	}
}

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
		//r.join();
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
	router.get("/ws", handleWebSockets((a)=>wsHandler(a)));

	auto listener = listenHTTP(settings, router);
	scope(exit) {
		foreach(ws; wrappers) {
			ws.waitTerminate = true;
			ws.close();
		}

		listener.stopListening();
	}

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
