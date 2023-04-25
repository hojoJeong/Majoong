package com.example.majoong.map.service;

import com.example.majoong.map.domain.Police;
import com.example.majoong.map.repository.PoliceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapRepositoryService {

    private final PoliceRepository policeRepository;

    @Transactional
    public List<Police> saveAll(List<Police> policeList) {
        if (CollectionUtils.isEmpty(policeList)) return Collections.emptyList();
        return policeRepository.saveAll(policeList);
    }
}
