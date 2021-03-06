module peer;

import pool;
import message;
import network;
import protocol.ver;
import protocol.commands;

import vibe.core.core;
import vibe.core.log;
import vibe.core.net;

import std.datetime;


/**
 * This class provides connection to enemy peer (client or server)
 */
class Peer {
    private Pool           m_pool;
    private SysTime        m_lastTime;
    private Networks       m_nets;
    private PeerState      m_state;
    private TCPConnection  m_socket;
    private NetworkAddress m_address;

    private bool m_hasValidVersion;
    private bool m_isServer;


    this(string address) {
        this(address, Network.DefaultPort, Networks.Live);
    }

    this(string address, Networks nets) {
        this(address, Network.DefaultPort, nets);
    }

    this(string address, ushort port, Networks nets) {
        auto net = resolveHost(address);
        net.port = port;

        this(net, nets);
    }

    this(NetworkAddress address, Networks nets) {
        m_nets    = nets;
        m_address = address;
        m_state   = PeerState.Disconnected;
    }

    // TODO: package?
    // dont call this directly
    this(TCPConnection socket, Networks nets) {
        m_nets    = nets;
        m_socket  = socket;
        m_state   = PeerState.Connected;
        m_address = socket.remoteAddress;

        runTask(&_receive);
        send(versionMessage);
    }

    Pool pool() {
        return m_pool;
    }

    void pool(Pool value) {
        m_pool = value;
    }

    ref bool isServer() {
        return m_isServer;
    }

    SysTime lastTime() const {
        return m_lastTime;
    }

    const(NetworkAddress) address() const {
        return m_address;
    }

    PeerState state() const {
        return m_state;
    }

    ref bool hasValidVersion() {
        return m_hasValidVersion;
    }

    void connect() {
        scope (failure) m_state = PeerState.Disconnected;
        m_state  = PeerState.Connecting;
        m_socket = connectTCP(m_address);
        m_state  = PeerState.Connected;

        runTask(&_receive);
        send(versionMessage);
    }

    void disconnect() {
        if (m_state == PeerState.Disconnected) {
            logDebug("trying to disconnect already disconnected peer!");
            return;
        }

        m_state = PeerState.Disconnected;
        m_socket.close();
        m_socket = TCPConnection.init;
    }

    void send(Message message) {
        logInfo("Sending message %s", message.command);
        m_socket.write(message.toArray);
    }


    private void _receive() {
        while (m_state == PeerState.Connected) {
            try {
                if (auto msg = Message.fromStream(m_socket)) {
                    m_lastTime = Clock.currTime();
                    parseMessage(this, msg);
                }
            } catch (Exception e) {
                m_state = PeerState.Disconnected;
                // TODO: notify about our state? pool.remove(this);
                logError("Disconnected");
                logError("%s", e);
                return;
            }
        }
    }
}


enum PeerState : ubyte {
    Disconnected,
    Connecting,
    Connected,
    Ready
}

