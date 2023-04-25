package com.example.majoong.map.util;

import com.opencsv.CSVReader;
import com.example.majoong.map.dto.PoliceDto;
import com.opencsv.exceptions.CsvValidationException;
import lombok.extern.slf4j.Slf4j;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Slf4j
public class CsvUtils {

    public static List<PoliceDto> convertToPoliceDtoList() {

        String file = "src/main/resources/static/facility/경찰서.csv";
        List<List<String>> csvList = new ArrayList<>();
        try (CSVReader csvReader = new CSVReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String[] values = null;
            while ((values = csvReader.readNext()) != null) {
                csvList.add(Arrays.asList(values));
            }
        } catch (IOException | CsvValidationException e) {
            log.error("CsvUtils convertToPharmacyDtoList Fail: {}", e.getMessage());
        }

        return IntStream.range(1, csvList.size()).mapToObj(index -> {
            List<String> rowList = csvList.get(index);

            return PoliceDto.builder()
                    .longitude(Float.parseFloat(rowList.get(0)))
                    .latitude(Float.parseFloat(rowList.get(1)))
                    .address(rowList.get(2))
                    .build();
        }).collect(Collectors.toList());
    }
}
