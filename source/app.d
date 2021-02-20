import vibe.vibe;
import twitter4d;
import std.stdio;
import std.regex;
import std.json;
import std.parallelism;
import std.algorithm;
import std.uri;
import core.thread;
import settings;

void safeWrite(string text)
{
	synchronized {
		writeln(text);
	}
}

// 文字列から救援IDを抽出
JSONValue parseText(JSONValue json)
{
	typeof(return) result;
	auto pattern = ctRegex!`救援ID:(?P<ID>[0-9]{10})\s参戦者募集！\s\s難易度:(?P<Lv>[A-Z]*)\s(?P<Name>.*)降臨！`;
	auto m = matchFirst(json["text"].str, pattern);

	result["id"] = m[1];
	result["level"] = m[2];
	result["name"] = m[3];

	return result;
}

bool readTweetTerminateFlag = false;
void readTweet()
{
	Twitter4D t4d = new Twitter4D([
		"consumerKey": twitterSettings.consumerKey,
		"consumerSecret": twitterSettings.consumerSecret,
		"accessToken": twitterSettings.accessToken,
		"accessTokenSecret": twitterSettings.accessTokenSecret
	]);

	string url = "https://stream.twitter.com/1.1/statuses/filter.json";
	string[string] params = ["track":"参戦者募集！"];

	writeln("start tweet reading ...");
	foreach(line; t4d.stream(url, params))
	{
		if(readTweetTerminateFlag) {
			break;
		}

		writeln("stream readed...");
		auto s = line.to!string;
		if(match(s, regex(r"\{.*\}"))){
			auto j = parseJSON(s);

			if ("media" in j["entities"]) { continue; }

			j = parseText(j);
			wsSend(j.toString);
		}
	}
	safeWrite("readTweet terminated.");
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

			auto recieved = socket.receiveText;
			safeWrite(recieved);
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

//void test()
//{
//	while(true)
//	{
//		sleep(dur!("seconds")(3));
//
//		foreach(s; wrappers) {
//			if (s.connected) {
//				wsSend("{'test':'aaa'}");
//			}
//		}
//	}
//}

void main()
{
	auto t = runTask(&readTweet);
	//auto r = runTask(&test);
	scope(exit)
	{
		readTweetTerminateFlag = true;
		t.join();
		//r.join();
	}

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	settings.sessionStore = new MemorySessionStore;

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
