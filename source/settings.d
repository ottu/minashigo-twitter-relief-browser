module settings;

import std.json;
import std.file;
import std.stdio;
import std.path;
import std.conv;

template CTFE(alias F) if (__traits(compiles, F())) { enum CTFE = F(); }

public static immutable TwitterSettings twitterSettings = CTFE!(load_twitter_settings);

struct TwitterSettings
{
    string consumerKey;
    string consumerSecret;
    string accessToken;
    string accessTokenSecret;
}

TwitterSettings load_twitter_settings()
{
    auto settings = TwitterSettings();

    auto json = parseJSON(cast(char[])import("twitter.json"));

    with(settings)
    {
        consumerKey = json["consumerKey"].str;
        consumerSecret = json["consumerSecret"].str;
        accessToken = json["accessToken"].str;
        accessTokenSecret = json["accessTokenSecret"].str;

    }

    return settings;
}