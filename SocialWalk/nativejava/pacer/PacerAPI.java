package pacer;

import javax.xml.bind.DatatypeConverter;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PacerAPI {

    public static String CLIENT_SECRET = "d3e8253d775940019ec0f3e116d5239c";
    public static String CLIENT_ID = "pacer_87873ea9f8d04d8db4d97ad0df81574b";
    public static String REDIRECT_URI = "http://localhost:8080/SocialWalk/authorize";

    public static String authorizeURL() {
        return String.format("http://developer.mypacer.com/oauth2/dialog?client_id=%s&redirect_uri=%s", CLIENT_ID, REDIRECT_URI);
    }

    public static String createAccessToken(String code) {
        try {
            URL url = new URL("http://openapi.mypacer.com/oauth2/access_token");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Authorization", getAuthorization());
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("Accept", "application/json; charset=UTF-8\"");
            con.setDoOutput(true);
            String body = String.format("{\"client_id\": \"%s\", \"code\": \"%s\", \"grant_type\": \"authorization_code\"}", CLIENT_ID, code);
            try(OutputStream os = con.getOutputStream()) {
                byte[] input = body.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            System.out.println(con.getResponseCode());
            try(BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                System.out.println(response.toString());
                return response.toString();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String refreshAccessToken(String refresh_token) {
        try {
            URL url = new URL("http://openapi.mypacer.com/oauth2/access_token");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Authorization", getAuthorization());
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("Accept", "application/json; charset=UTF-8\"");
            con.setDoOutput(true);
            String body = String.format("{\"client_id\": \"%s\", \"refresh_token\": \"%s\", \"grant_type\": \"refresh_token\"}", CLIENT_ID, refresh_token);
            try(OutputStream os = con.getOutputStream()) {
                byte[] input = body.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            System.out.println(con.getResponseCode());
            try(BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                System.out.println(response.toString());
                return response.toString();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getUserInfo(String user_id, String access_token) {
        try {
            URL url = new URL("http://openapi.mypacer.com/users/" + user_id);
            System.out.println(url);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Authorization", "Bearer " + access_token);
            try(BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                System.out.println(response.toString());
                return response.toString();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getDailyActivities(String user_id, String access_token, String start_date, String end_date) {
        try {
            URL url = new URL(String.format("http://openapi.mypacer.com/users/%s/activities/daily.json?start_date=%s&end_date=%s&accept_manual_input=false", user_id, start_date, end_date));
            System.out.println(url);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Authorization", "Bearer " + access_token);
            try(BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                System.out.println(response.toString());
                return response.toString();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getAuthorization() {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            String appSecretHash = DatatypeConverter.printHexBinary(md.digest((CLIENT_SECRET + "pacer_oauth").getBytes(StandardCharsets.UTF_8))).toLowerCase();
            System.out.println(appSecretHash);
            return DatatypeConverter.printHexBinary(md.digest((appSecretHash + CLIENT_ID).getBytes(StandardCharsets.UTF_8))).toLowerCase();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }
}
