module app;

import peer;
import pool;
import address;
import network;
import public_key;
import private_key;

import std.stdio;
import std.string;
import std.datetime;

import core.thread;

import vibe.core.core;

// TODO: -D path/to/dir/with/private_key + cache for my profile
// TODO: -p listening port, default 4295

shared static this() {
    runTask({
        auto dir = "todo pwd";

        writeln("Welcome to the DecNet!");
        writeln("Working directory: ", dir);

        auto pool = new Pool(Networks.Live);
        pool.connect();
        pool.listen();
        Thread.sleep(1.seconds);

        user1();

        /*string cmd;
        do {
            cmd = readln().strip();

            writeln("have :", cmd);

        } while (cmd != "exit");

        */

        Thread.sleep(5.seconds);
        writeln("exiting...");
        pool.disconnect();
    });
}


void user1() {
    /*auto privateKey = new PrivateKey;
    auto address    = privateKey.toPublicKey.toAddress();


    auto str = privateKey.toPIF();
    writeln("len: ", str.length);
    writeln("test: ", str);

    if (PrivateKey.isValid(str)) {
        PrivateKey.fromPIF(str);
    }


    writeln("addr: ", address.toString());
    */

    per = new Peer("127.0.0.1", 4295, Networks.Live);
    Thread.sleep(1.seconds);
    per.connect();

    Thread.sleep(1.seconds);
    //peer.disconnect();
}

Peer per;

void user2() {

}



void user(string[] cmd) {
    if (!cmd.length) {
        writeln("error: 0 length");
        return;
    }

    switch (cmd[0]) {
        case "create":
            break;

        default:
            writeln("error: unknown command");
    }
}

