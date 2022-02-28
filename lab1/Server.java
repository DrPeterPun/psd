import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class Server{

    public static void main(String[] args) throws IOException{
        ArrayList<ServerThread> threads = new ArrayList<>();
        
        try(ServerSocket serversocket = new ServerSocket(50000)){
            while(true){
                Socket s = serversocket.accept();
                ServerThread st = new ServerThread(s, threads);
            
                threads.add(st);
                st.start();
            }
            
        } catch (Exception e) {
            //TODO: handle exception
            System.out.println("Error mah man");
        }
    }
}