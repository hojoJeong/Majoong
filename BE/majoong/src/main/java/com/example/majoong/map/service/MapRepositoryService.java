package com.example.majoong.map.service;

import com.example.majoong.map.domain.Bell;
import com.example.majoong.map.domain.Cctv;
import com.example.majoong.map.domain.Police;
import com.example.majoong.map.domain.Store;
import com.example.majoong.map.dto.PoliceDto;
import com.example.majoong.map.repository.PoliceRepository;
import com.example.majoong.map.repository.StoreRepository;
import com.example.majoong.map.util.CsvUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapRepositoryService {

    private final PoliceRepository policeRepository;
    private final StoreRepository storeRepository;

    public void saveCsvToMysql() {
//        List<Police> policeList = mapRepositoryService.loadPoliceList();
//        List<Store> storeList = mapRepositoryService.loadStoreList();
//        List<Cctv> cctvList = mapRepositoryService.loadCctvList();
//        List<Bell> bellList = mapRepositoryService.loadBellList();
        log.info("load success");


//        mapRepositoryService.saveEntity(policeList, policeRepository);
//        mapRepositoryService.saveEntity(storeList, storeRepository);
//        mapRepositoryService.saveEntity(cctvList, cctvRepository);
//        mapRepositoryService.saveEntity(bellList, bellRepository);
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

//    @Transactional
//    public List<Police> saveAll(List<Police> policeList) {
//        if (CollectionUtils.isEmpty(policeList)) return Collections.emptyList();
//        return policeRepository.saveAll(policeList);
//    }

    @Transactional
    public <T> List<T> saveEntity(List<T> entityList, JpaRepository<T, Long> repository) {
        if (CollectionUtils.isEmpty(entityList)) {
            return Collections.emptyList();
        }
        return repository.saveAll(entityList);
    }

    @Transactional(readOnly = true)
    public <T> List<T> findEntity(JpaRepository<T, Long> repository) {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Police> findAll() {
        return policeRepository.findAll();
    }
}
