package com.example.majoong.path.service;

import com.example.majoong.path.Repository.NodeRepository;
import com.example.majoong.path.domain.Node;
import com.example.majoong.path.dto.GraphDto;
import com.example.majoong.path.dto.NodeDto;
import com.example.majoong.path.dto.PointDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class PathService {

    @Value("${google.maps.api.key}")
    private String API_KEY;
    private String API_URL = "https://";

    private GraphDto aStarGraph;
    @Autowired
    private NodeRepository nodeRepository;

    public List<PointDto> getRecommendedPath(double startLng, double startLat, double endLng, double endLat) {

        // 시작점, 도착점과 가장 가까운 노드 탐색
        NodeDto startNode = findNearestNode(startLng, startLat);
        NodeDto endNode = findNearestNode(endLng, endLat);

        // 그래프 생성
        createAstarGraph(startNode, endNode);

        // astar 알고리즘
        List<PointDto> recommendedPath = astar(startNode.getNodeId(), endNode.getNodeId());

        return recommendedPath;
    }

    public List<PointDto> getShortestPath(double startLng, double startLat, double endLng, double endLat) {

        List<PointDto> shortestPath = new ArrayList<>();

        return shortestPath;
    }

    public NodeDto findNearestNode(double lng, double lat) {

        NodeDto nearestNode = new NodeDto();
        nearestNode.setId(0);
        nearestNode.setLng(lng);
        nearestNode.setLat(lat);

        return nearestNode;
    }

    public void createAstarGraph(NodeDto startNode, NodeDto endNode) {

        aStarGraph = new GraphDto();
    }

    // extend comparator.
    // 노드 데이터끼리 총 비용을 비교할 수 있도록 Comparator 재정의
    public class NodeComparator implements Comparator<NodeDto> {
        public int compare(NodeDto nodeFirst, NodeDto nodeSecond) {
            if (nodeFirst.getF() < nodeSecond.getF()) return -1;    // F : 거리 + 안전수치
            if (nodeSecond.getF() > nodeFirst.getF()) return 1;
            return 0;
        }
    }

    // 경로 반환하는 메서드
    private List<Long> path(Map<Long, Long> cameFrom, Long destinationId) {
        // assert boolean 식;       boolean 식이 true인 경우에만 프로그램이 실행
        assert cameFrom != null;
        assert destinationId != null;

        final List<Long> pathList = new ArrayList<>();
        pathList.add(destinationId);
        while (cameFrom.containsKey(destinationId)) {
            destinationId = cameFrom.get(destinationId);
            pathList.add(destinationId);
        }
        Collections.reverse(pathList);
        return pathList;
    }

    public List<PointDto> astar(Long sourceId, Long   destinationId) {

        System.out.println("START : " + sourceId + "              END : "+  destinationId);

        /**
         * http://stackoverflow.com/questions/20344041/why-does-priority-queue-has-default-initial-capacity-of-11
         */
        // 우선선위 큐(초기 용량, 비교수단 Comparator)
        final Queue<NodeDto> openQueue = new PriorityQueue<NodeDto>(11, new NodeComparator());


        Node sourceNode = nodeRepository.findById(sourceId).get(); // sourceId로 source에 해당하는 노드 정보 가져오기
        NodeDto sourceNodeDto = new NodeDto();
        sourceNodeDto.setLng(sourceNode.getLongitude());
        sourceNodeDto.setLat(sourceNode.getLatitude());
        sourceNodeDto.setG(0); // 출발지점 0
        sourceNodeDto.calcF(destinationId); // 도착지까지의 총 비용 계산
        openQueue.add(sourceNodeDto); // 출발 노드 큐에 삽입

        // key: 노드, value : 부모 노드   -> 키에 해당하는 노드는 value에 해당하는 노드를 거쳐서 왔다는 뜻
        final Map<Long, Long> cameFrom = new HashMap<Long, Long>(); // 경로 Map
        final Set<NodeDto> closedList = new HashSet<NodeDto>(); // 닫힌 목록 -> 더 이상 볼 필요 없는 목록

        // 큐 : 열린 목록
        // 큐가 비기 전 까지 무한 반복 -> 큐가 빈거면 경로가 없다는 뜻
        while (!openQueue.isEmpty()) {

            final NodeDto nodeDto = openQueue.poll();  // 큐에서 하나 poll

            // 도착지 노드 발견하면 경로에 추가하고 종료
            if (nodeDto.getNodeId().equals(destinationId)) {
                List<Long> temp = path(cameFrom, destinationId);
                List<NodeDto> result = new ArrayList<>();
                for(long id : temp){
                    result.add(nodeRepository.findById(id));
                }
                return result;
            }

            // poll한 노드 닫힌 목록에 추가
            closedList.add(nodeData);

            // poll한 노드의 인접 노드를 하나씩 뽑아서 진행
            for (Map.Entry<NodeData, Double> neighborEntry : graph.edgesFrom(nodeData.getNodeId()).entrySet()) {
                // entrySet() : Returns a Set view of the mappings contained in this map.

                NodeData neighbor = neighborEntry.getKey();

                // 닫힌 목록에 있으면 볼 필요 없음
                if (closedList.contains(neighbor)) continue;

                double distanceBetweenTwoNodes = neighborEntry.getValue();  // 두 노드 사이의 비용
                double tentativeG = distanceBetweenTwoNodes + nodeData.getG();  // 두 노드 사이의 비용 + poll한 노드의 G값

                // poll한 노드 거쳐서 온 G값이 더 작으면 G값 변경
                if (tentativeG < neighbor.getG()) {
                    neighbor.setG(tentativeG);
                    neighbor.calcF(  destination);

                    // 경로 map에 추가 -> 내가 어디서 왔는가 ( 자기 부모(?) 노드 입력 )
                    cameFrom.put(neighbor.getNodeId(), nodeData.getNodeId());
                    // 큐에 이웃이 포함 안되어 있으면 추가
                    if (!openQueue.contains(neighbor)) {
                        openQueue.add(neighbor);
                    }
                }
            }
        }
        return null;
    }
}