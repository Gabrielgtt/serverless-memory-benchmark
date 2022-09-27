package factorial;

public class App {

    public int factorial(int n) {
        if(n == 0) {
            return 1;
        } else {
            return (n * factorial(n-1)) % 1000000007;
        }
    }

    public Response handler(Request request) {

        int number = this.factorial(request.n);

        return new Response(number);
    }
}
