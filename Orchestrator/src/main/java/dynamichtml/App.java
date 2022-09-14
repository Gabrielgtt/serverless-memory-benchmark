package dynamichtml;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import com.google.common.base.Charsets;
import com.google.common.io.Resources;
import com.hubspot.jinjava.Jinjava;

public class App 
{

    private List<Integer> randomNumbers(int min, int max, int size) {
        List<Integer> numbers = new ArrayList<Integer>();

        Random r = new Random();

        while(numbers.size() < size) {
            int number = r.nextInt(max-min) + min;

            numbers.add(number);
        }


        return numbers;
    }

    public Response handler(Request request) throws IOException {

        List<Integer> randomNumbers = randomNumbers(0, 1000000, request.randomLen);
        
        Jinjava jinjava = new Jinjava();

        Map<String, Object> context = new HashMap<String, Object>();
        context.put("username", request.username);
        LocalDateTime currentTime = LocalDateTime.now();
        context.put("cur_time", currentTime);
        context.put("random_numbers", randomNumbers);
        
        String template = Resources.toString(Resources.getResource("template.html"), Charsets.UTF_8);
        
        String renderedTemplate = jinjava.render(template, context);

        return new Response(renderedTemplate);
    }
}
