package fibonacci;

public class App {

    public int fibonacci(int n) {
        if (n == 0) {
            return 0;
        } else if(n == 1) {
            return 1;
        } else {
            return (fibonacci(n-1) + fibonacci(n-2)) % 1000000007;
        }
    }

    public Response handler(Request request) {

        int number = this.fibonacci(request.n);

        return new Response(number);
    }
}
