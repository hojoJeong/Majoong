package com.example.majoong.tools;

import com.example.majoong.map.dto.BellDto;
import com.example.majoong.map.dto.CctvDto;
import com.example.majoong.map.dto.StoreDto;
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

    public static List<PoliceDto> convertToPoliceDtoList(String category) {

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

        return IntStream.range(0, csvList.size()).mapToObj(index -> {
            List<String> rowList = csvList.get(index);

            return PoliceDto.builder()
                    .lng(Double.parseDouble(rowList.get(0)))
                    .lat(Double.parseDouble(rowList.get(1)))
                    .address(rowList.get(2))
                    .build();
        }).collect(Collectors.toList());
    }

    public static List<StoreDto> convertToStoreDtoList(String category) {

        String file = "src/main/resources/static/facility/편의점.csv";

        List<List<String>> csvList = new ArrayList<>();
        try (CSVReader csvReader = new CSVReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String[] values = null;
            while ((values = csvReader.readNext()) != null) {
                csvList.add(Arrays.asList(values));
            }
        } catch (IOException | CsvValidationException e) {
            log.error("CsvUtils convertToPharmacyDtoList Fail: {}", e.getMessage());
        }

        return IntStream.range(0, csvList.size()).mapToObj(index -> {
            List<String> rowList = csvList.get(index);

            return StoreDto.builder()
                    .lng(Double.parseDouble(rowList.get(0)))
                    .lat(Double.parseDouble(rowList.get(1)))
                    .address(rowList.get(2))
                    .build();
        }).collect(Collectors.toList());
    }

    public static List<CctvDto> convertToCctvDtoList(String category) {

        String file = "src/main/resources/static/facility/CCTV.csv";

        List<List<String>> csvList = new ArrayList<>();
        try (CSVReader csvReader = new CSVReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String[] values = null;
            while ((values = csvReader.readNext()) != null) {
                csvList.add(Arrays.asList(values));
            }
        } catch (IOException | CsvValidationException e) {
            log.error("CsvUtils convertToPharmacyDtoList Fail: {}", e.getMessage());
        }

        return IntStream.range(0, csvList.size()).mapToObj(index -> {
            List<String> rowList = csvList.get(index);

            return CctvDto.builder()
                    .lng(Double.parseDouble(rowList.get(0)))
                    .lat(Double.parseDouble(rowList.get(1)))
                    .address(rowList.get(2))
                    .build();
        }).collect(Collectors.toList());
    }

    public static List<BellDto> convertToBellDtoList(String category) {

        String file = "src/main/resources/static/facility/비상벨.csv";

        List<List<String>> csvList = new ArrayList<>();
        try (CSVReader csvReader = new CSVReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String[] values = null;
            while ((values = csvReader.readNext()) != null) {
                csvList.add(Arrays.asList(values));
            }
        } catch (IOException | CsvValidationException e) {
            log.error("CsvUtils convertToPharmacyDtoList Fail: {}", e.getMessage());
        }

        return IntStream.range(0, csvList.size()).mapToObj(index -> {
            List<String> rowList = csvList.get(index);

            return BellDto.builder()
                    .lng(Double.parseDouble(rowList.get(0)))
                    .lat(Double.parseDouble(rowList.get(1)))
                    .address(rowList.get(2))
                    .build();
        }).collect(Collectors.toList());
    }

    // fileName에 사용
    public enum EntityCategory {
        POLICE("경찰서.csv"),
        STORE("편의점.csv"),
        CCTV("CCTV.txt");

        private final String fileName;

        EntityCategory(String fileName) {
            this.fileName = fileName;
        }

        public String getFileName() {
            return fileName;
        }
    }
}
