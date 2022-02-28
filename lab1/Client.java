import java.util.ArrayList;

public class Client{
    int delay;
    int size = 32;
    
    public static void main(String[] args) {
        int delay = Integer.parseInt(args[0]); 
        int quant = Integer.parseInt(args[1]);

        ArrayList<Client> cs = new ArrayList<>();

        for (int i = 0; i < quant; i++) {
            cs.add(new ClientThread(delay,socket));
        }
    }

    public Client (int d){
        this.delay = d;
    }


}