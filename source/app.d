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
		auto s = line.to!string;
		writeln(s);
		if(match(s, regex(r"\{.*\}"))){
			auto j = parseJSON(s);
			safeWrite(j.toPrettyString);

			if ("media" in j["entities"]) { continue; }

			wsSend(j.toPrettyString);
		}
	}
}

WebSocket [] wss;

void wsHandler(scope WebSocket socket)
{
	wss ~= socket;
	while (socket.waitForData)
	{
		auto recieved = socket.receiveText;
		safeWrite(recieved);
	}
}

void wsSend(string text)
{
	safeWrite(text);
	foreach(s; wss)
	{
		s.send(text);
	}
}

void main()
{
	readTweet();
	//auto t = runTask(&readTweet);
	//auto t = new Thread(()=>readTweet).start();

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "0.0.0.0"];
	settings.sessionStore = new MemorySessionStore;

	auto router = new URLRouter;
	router.registerWebInterface(new WebService);
	router.get("*", serveStaticFiles("public/"));
	router.get("/ws", handleWebSockets((a)=>wsHandler(a)));

	listenHTTP(settings, router);

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
