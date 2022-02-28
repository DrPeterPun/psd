import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.channels.spi.SelectorProvider;
import java.util.Iterator;
import java.util.logging.Handler;

public class EchoServer {
   
    public EchoServer( ) throws IOException {
        Selector sel = SelectorProvider.provider().openSelector();

        while (true) {
            sel.select();
            for (Iterator<SelectionKey> i=sel.selectedKeys().iterator(); i.hasNext(); ) {
                // i/o operations

                SelectionKey key = i.next();
               
                //abrir a socket
                ServerSocketChannel ss = ServerSocketChannel.open();
                //binding to port
                ss.bind(new InetSocketAddress(12345));
                // configure as to not block
                ss.configureBlocking(false);
                ss.register(sel, SelectionKey.OP_ACCEPT);

                // try to accept connection
                if (key.isAcceptable()) {
                    SocketChannel s =ss.accept();

                    if (s!=null) {
                        s.configureBlocking(false);
                        s.register(sel, SelectionKey.OP_READ)
                            .attach(new ChatSession(/*argumentos aqui*/));
                    }
                } else if (key.isReadable()) {
                    ChatSession h =(ChatSession)key.attachment();
                    ByteBuffer buf = ByteBuffer.allocate(100);
                    ((SocketChannel)key.channel()).read(buf);
                    h.handleRead(buf);
                    } else if (key.isWritable()) {
                    ChatSession handler=(ChatSession)key.attachment();
                    handler.handleWrite();
                    }   
                }




                i.remove();
            }
        }
    }
}