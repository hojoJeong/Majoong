package com.example.majoong.map.service;

import com.example.majoong.map.domain.Bell;
import com.example.majoong.map.domain.Cctv;
import com.example.majoong.map.domain.Police;
import com.example.majoong.map.domain.Store;
import com.example.majoong.map.repository.BellRepository;
import com.example.majoong.map.repository.CctvRepository;
import com.example.majoong.map.repository.PoliceRepository;
import com.example.majoong.map.repository.StoreRepository;
import com.example.majoong.tools.CsvUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.data.geo.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.redis.core.GeoOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapDataService {
    private final RedisTemplate<String, Object> redisTemplate;
    private final PoliceRepository policeRepository;
    private final StoreRepository storeRepository;
    private final CctvRepository cctvRepository;
    private final BellRepository bellRepository;

    public void saveMysqlToRedisGeospatial() {
//        savePoliceToRedis();
//        saveStoreToRedis();
//        saveCctvToRedis();
        saveBellToRedis();
        log.info("save success");
    }

    public void saveCsvToMysql() {
//        List<Police> policeList = loadPoliceList();
//        List<Store> storeList = loadStoreList();
//        List<Cctv> cctvList = loadCctvList();
        List<Bell> bellList = loadBellList();
        log.info("load success");

//        saveEntity(policeList, policeRepository);
//        saveEntity(storeList, storeRepository);
//        saveEntity(cctvList, cctvRepository);
        saveEntity(bellList, bellRepository);
        log.info("save success");
    }

    public List<Police> loadPoliceList() {
        return CsvUtils.convertToPoliceDtoList("police")
                .stream().map(policeDto -> Police.builder()
                        .policeId(policeDto.getPoliceId())
                        .longitude(policeDto.getLongitude())
                        .latitude(policeDto.getLatitude())
                        .address(policeDto.getAddress())
                        .build())
                .collect(Collectors.toList());
    }

    public List<Store> loadStoreList() {
        return CsvUtils.convertToStoreDtoList("store")
                .stream().map(storeDto -> Store.builder()
                        .storeId(storeDto.getStoreId())
                        .longitude(storeDto.getLongitude())
                        .latitude(storeDto.getLatitude())
                        .address(storeDto.getAddress())
                        .build())
                .collect(Collectors.toList());
    }

    public List<Cctv> loadCctvList() {
        return CsvUtils.convertToCctvDtoList("cctv")
                .stream().map(cctvDto -> Cctv.builder()
                        .cctvId(cctvDto.getCctvId())
                        .longitude(cctvDto.getLongitude())
                        .latitude(cctvDto.getLatitude())
                        .address(cctvDto.getAddress())
                        .build())
                .collect(Collectors.toList());
    }

    public List<Bell> loadBellList() {
        return CsvUtils.convertToBellDtoList("bell")
                .stream().map(bellDto -> Bell.builder()
                        .bellId(bellDto.getBellId())
                        .longitude(bellDto.getLongitude())
                        .latitude(bellDto.getLatitude())
                        .address(bellDto.getAddress())
                        .build())
                .collect(Collectors.toList());
    }

    public <T> List<T> saveEntity(List<T> entityList, JpaRepository<T, Long> repository) {
        if (CollectionUtils.isEmpty(entityList)) {
            return Collections.emptyList();
        }
        return repository.saveAll(entityList);
    }

    private void savePoliceToRedis() {
        String key = "police";
        List<Police> policeList = policeRepository.findAll();
        for (Police police : policeList) {
            String id = police.getPoliceId().toString();
            String address = police.getAddress();
            Double longitude = police.getLongitude();
            Double latitude = police.getLatitude();
            String member = id + "_" + address;
            if (Objects.isNull(police)) {
                log.error("value가 비었습니다.");
                return;
            }
            try {
                GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
                geoOperations.add(key, new Point(longitude, latitude), member);
                System.out.println(member);
//                log.info("저장성공", member);
            } catch (Exception e) {
                log.error("저장실패", e.getMessage());
            }
        }
    }

    private void saveStoreToRedis() {
        String key = "store";
        List<Store> storeList = storeRepository.findAll();
        for (Store store : storeList) {
            String id = store.getStoreId().toString();
            String address = store.getAddress();
            Double longitude = store.getLongitude();
            Double latitude = store.getLatitude();
            String member = id + "_" + address;
            if (Objects.isNull(store)) {
                log.error("value가 비었습니다.");
                return;
            }
            try {
                GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
                geoOperations.add(key, new Point(longitude, latitude), member);
                System.out.println(member);
//                log.info("저장성공", member);
            } catch (Exception e) {
                log.error("저장실패", e.getMessage());
            }
        }
    }

    private void saveCctvToRedis() {
        String key = "cctv";
        List<Cctv> cctvList = cctvRepository.findAll();
        for (Cctv cctv : cctvList) {
            String id = cctv.getCctvId().toString();
            String address = cctv.getAddress();
            Double longitude = cctv.getLongitude();
            Double latitude = cctv.getLatitude();
            String member = id + "_" + address;
            if (Objects.isNull(cctv)) {
                log.error("value가 비었습니다.");
                return;
            }
            try {
                GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
                geoOperations.add(key, new Point(longitude, latitude), member);
                System.out.println(member);
//                log.info("저장성공", member);
            } catch (Exception e) {
                log.error("저장실패", e.getMessage());
            }
        }
    }

    private void saveBellToRedis() {
        String key = "bell";
        List<Bell> bellList = bellRepository.findAll();
        for (Bell bell : bellList) {
            String id = bell.getBellId().toString();
            String address = bell.getAddress();
            Double longitude = bell.getLongitude();
            Double latitude = bell.getLatitude();
            String member = id + "_" + address;
            if (Objects.isNull(bell)) {
                log.error("value가 비었습니다.");
                return;
            }
            try {
                GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
                geoOperations.add(key, new Point(longitude, latitude), member);
                System.out.println(member);
//                log.info("저장성공", member);
            } catch (Exception e) {
                log.error("저장실패", e.getMessage());
            }
        }
    }
}
