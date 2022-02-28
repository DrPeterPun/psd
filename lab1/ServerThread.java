import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;

public class ServerThread extends Thread{
    public ArrayList<ServerThread> serverthreads;
    public Socket socket;
    public PrintWriter output;

    public ServerThread(Socket s, ArrayList<ServerThread> st){
        this.serverthreads = st;
        this.socket = s;
    }

    public void run() {
        try {
            // creating the input stream to recceive messages
            BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));

            this.output = new PrintWriter(socket.getOutputStream(), true);

            //thread loop, always reading and writing what it read to all clients
            while (true) {
                String opstream = input.readLine();
                printAll(opstream);
                System.out.println("R " + this.socket  +":+ opstream");
            }
        } catch (Exception e) {
            //TODO: handle exception
        }
    }

    // sends the message to all clients
    private void printAll(String s){
        for(ServerThread st: serverthreads){
            st.output.println();
        }
    }
}
