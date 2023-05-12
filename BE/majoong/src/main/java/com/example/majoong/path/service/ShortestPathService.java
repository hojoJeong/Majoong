package com.example.majoong.path.service;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.path.dto.PathInfoDto;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ShortestPathService {
    private final String API_BASE_URL = "https://apis.openapi.sk.com/tmap/routes/pedestrian";
    private static final MediaType MEDIA_TYPE_FORM = MediaType.parse("application/x-www-form-urlencoded");
    @Value("${map.api.key}")
    private String API_KEY;

    public PathInfoDto getShortestPath(double startLng, double startLat, double endLng, double endLat) throws IOException {
        String startX = Double.toString(startLng);
        String startY = Double.toString(startLat);
        String endX = Double.toString(endLng);
        String endY = Double.toString(endLat);
        String reqCoordType = "WGS84GEO";
        String resCoordType = "WGS84GEO";
        double distance = 0; //미터

        String requestBody = "startX=" + startX +
                "&startY=" + startY +
                "&endX=" + endX +
                "&endY=" + endY +
                "&reqCoordType=" + reqCoordType +
                "&resCoordType=" + resCoordType +
                "&startName=start&endName=end";

        Request request = new Request.Builder()
                .url(API_BASE_URL)
                .addHeader("appKey", API_KEY)
                .addHeader("Accept-Language", "ko")
                .post(RequestBody.create(MEDIA_TYPE_FORM, requestBody))
                .build();

        OkHttpClient client = new OkHttpClient();

        Response response = client.newCall(request).execute();
        if (response.isSuccessful()) {
            String jsonData = response.body().string();
            JsonElement jsonElement = JsonParser.parseString(jsonData);
            JsonObject jsonObject = jsonElement.getAsJsonObject();
            JsonArray features = jsonObject.getAsJsonArray("features");

            List<LocationDto> pointList = new ArrayList<>();

            for (JsonElement featureElement : features) {
                JsonObject feature = featureElement.getAsJsonObject();
                JsonObject geometry = feature.getAsJsonObject("geometry");

                String geometryType = geometry.get("type").getAsString();
                JsonArray coordinates = geometry.getAsJsonArray("coordinates");

                if (geometryType.equals("Point")) {
                    double longitude = coordinates.get(0).getAsDouble();
                    double latitude = coordinates.get(1).getAsDouble();
                    LocationDto location = new LocationDto(longitude,latitude);
                    if (pointList.isEmpty() || !pointList.get(pointList.size() - 1).equals(location)) {
                        pointList.add(location);
                    }
                } else if (geometryType.equals("LineString")) {
                    distance += feature.getAsJsonObject("properties").get("distance").getAsInt();

                    for (JsonElement coordinateElement : coordinates) {
                        JsonArray coordinateArray = coordinateElement.getAsJsonArray();
                        double longitude = coordinateArray.get(0).getAsDouble();
                        double latitude = coordinateArray.get(1).getAsDouble();
                        LocationDto location = new LocationDto(longitude,latitude);
                        if (pointList.isEmpty() || !pointList.get(pointList.size() - 1).equals(location)) {
                            pointList.add(location);
                        }
                    }
                } else {
                    System.out.println("Request failed: " + response.code() + " - " + response.message());
                }
            }
            PathInfoDto path = new PathInfoDto();
            path.setDistance((int) distance);
            path.setTime((int)(distance/1000/5*60));
            path.setPoint(pointList);
            return path;}
        return null;
    }}

