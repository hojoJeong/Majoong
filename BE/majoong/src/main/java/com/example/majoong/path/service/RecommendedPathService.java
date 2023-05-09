package com.example.majoong.path.service;

import com.example.majoong.path.Repository.NodeRepository;
import com.example.majoong.path.domain.Node;
import com.example.majoong.path.dto.EdgeDto;
import com.example.majoong.path.dto.GraphDto;
import com.example.majoong.path.dto.NodeDataDto;
import com.example.majoong.path.dto.NodeDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class RecommendedPathService {

    private GraphDto astarGraph;
    @Autowired
    private NodeRepository nodeRepository;

    public List<NodeDto> getRecommendedPath(double startLng, double startLat, double endLng, double endLat) {

        // 시작점, 도착점과 가장 가까운 노드 탐색
        NodeDto startNode = findNearestNode(startLng, startLat);
        NodeDto endNode = findNearestNode(endLng, endLat);

        // 그래프 생성
//        createAstarGraph(startNode, endNode);

        // astar 알고리즘
        List<NodeDto> recommendedPath = astar(startNode.getNodeId(), endNode.getNodeId());

        return recommendedPath;
    }

    // postGIS를 이용해서 좌표에서 가장 가까운 도로 노드 반환
    public NodeDto findNearestNode(double lng, double lat) {

        Node nearestNode = nodeRepository.findNearestNode(lng, lat);

        NodeDto nearestNodeDto = new NodeDto();
        nearestNodeDto.setNodeId(nearestNode.getNodeId());
        nearestNodeDto.setLng(nearestNode.getLng());
        nearestNodeDto.setLat(nearestNode.getLat());

        return nearestNodeDto;
    }

    // 시작점에서 도착지까지 경로 탐색에 사용할 그래프 생성
//    public void createAstarGraph(NodeDto startNode, NodeDto endNode) {
//
//        // startNode와 endNode 기준 영역 안의 모든 node, edge 정보 가져오기
//        Map<String,List<?>> nodeEdge = searchNodeEdgeForGraph_ai(lat1, lng1, lat2, lng2);
//
//        List<NodeDto> nodeList = (List<NodeDto>) nodeEdge.get("nodes");      //영역 안의 모든 노드정보
//        List<EdgeDto> edgeList = (List<EdgeDto>) nodeEdge.get("edges");      //영역 안의 모든 엣지정보
//
//        Map<Long, Map<Long, Double>> heuristicMap = new HashMap<Long, Map<Long, Double>>(); //휴리스틱 값
//
//        if(nodeList.size() < 2){
//            // 노드 개수가 두개 미마인 경우, 휴리스틱 값이 없음
//            // 바로 연결 or 예외 처리
//        }
//        else {
//            //노드 개수가 두개 이상일 경우,
//            for (NodeDto source : nodeList) {
//                HashMap<Long, Double> tempMap = new HashMap<>();
//                for (NodeDto target : nodeList) {
//                    if (source.getNodeId().equals(target.getNodeId())) {
//                        // 시작과 끝이 같은 경우, 휴리스티 값 0
//                        tempMap.put(target.getNodeId(), 0.0);
//                    } else {
//                        double safetyRate = calcHeuristicVal(source.getLng(), source.getLat(), target.getLng(), target.getLat(), edgeList);
//                        tempMap.put(target.getNodeId(), safetyRate);
//                    }
//                }
//
//                heuristicMap.put(source.getNodeId(), tempMap);
//            }
//        }
////        graph= new GraphAStar(nodes, edges, heuristicMap);
//
//        astarGraph = new GraphDto(nodeList, edgeList, heuristicMap);
//    }

    public List<NodeDto> astar(Long sourceId, Long destinationId) {

        System.out.println("START : " + sourceId + "              END : "+  destinationId);

        /**
         * http://stackoverflow.com/questions/20344041/why-does-priority-queue-has-default-initial-capacity-of-11
         */
        // 우선선위 큐(초기 용량, 비교수단 Comparator)
        final Queue<NodeDataDto> openQueue = new PriorityQueue<NodeDataDto>(11, new NodeComparator());

        // 그래프의 소스노드 부터 시작
        NodeDataDto sourceNodeDataDto = astarGraph.getNodeData(sourceId);

        sourceNodeDataDto.setG(0); // 출발지점 0
        sourceNodeDataDto.calcF(destinationId); // 도착지까지의 총 비용 계산
        openQueue.add(sourceNodeDataDto); // 출발 노드 큐에 삽입

        // key: 노드, value : 부모 노드   -> 키에 해당하는 노드는 value에 해당하는 노드를 거쳐서 왔다는 뜻
        final Map<Long, Long> cameFrom = new HashMap<Long, Long>(); // 경로 Map
        final Set<Long> closedList = new HashSet<>(); // 닫힌 목록 -> 더 이상 볼 필요 없는 목록

        // 큐 : 열린 목록
        // 큐가 비기 전 까지 무한 반복 -> 큐가 빈거면 경로가 없다는 뜻
        while (!openQueue.isEmpty()) {

            final NodeDataDto nodeDataDto = openQueue.poll();  // 큐에서 하나 poll

            // 도착지 노드 발견하면 경로에 추가하고 종료
            if (nodeDataDto.getNodeId().equals(destinationId)) {
                List<Long> pathList = getPathList(cameFrom, destinationId);
                List<NodeDto> result = new ArrayList<>();
                for(long id : pathList){
                    Node resultNode = nodeRepository.findById(id).get();
                    result.add(new NodeDto(id, resultNode.getLng(), resultNode.getLat()));
                }
                return result;
            }

            // poll한 노드 닫힌 목록에 추가
            closedList.add(nodeDataDto.getNodeId());

            // poll한 노드의 인접 노드를 하나씩 뽑아서 진행
            for (Map.Entry<NodeDataDto, Double> neighborEntry : astarGraph.edgesFrom(nodeDataDto.getNodeId()).entrySet()) {
                // 인접 노드
                NodeDataDto neighbor = neighborEntry.getKey();

                // 닫힌 목록에 있으면 볼 필요 없음
                if (closedList.contains(neighbor.getNodeId())) continue;

                double distanceBetweenTwoNodes = neighborEntry.getValue();  // 두 노드 사이의 비용
                double tentativeG = distanceBetweenTwoNodes + nodeDataDto.getG();  // 두 노드 사이의 비용 + poll한 노드의 G값

                // poll한 노드 거쳐서 온 G값이 더 작으면 G값 변경
                if (tentativeG < neighbor.getG()) {
                    neighbor.setG(tentativeG);
                    neighbor.calcF(destinationId);

                    // 경로 map에 추가 -> 내가 어디서 왔는가 ( 부모 노드 입력 )
                    cameFrom.put(neighbor.getNodeId(), nodeDataDto.getNodeId());
                    // 큐에 이웃이 포함 안되어 있으면 추가
                    if (!openQueue.contains(neighbor)) {
                        openQueue.add(neighbor);
                    }
                }
            }
        }
        return null;
    }

//    public double calcHeuristicVal(double lng1, double lat1, double lng2, double lat2, List<EdgeDto> edgeList){
//
//        // 1번 : 왼쪽아래, 2번 : 오른쪽위 로 오도록 세팅
//        if(!(lat1 < lat2)){
//            double temp = lat1;
//            lat1 = lat2;
//            lat2 = temp;
//        }
//        if(!(lng1 < lng2)){
//            double temp = lng1;
//            lng1= lng2;
//            lng2=temp;
//        }
//
//        double lat = 0.0;
//        double lng = 0.0;
//        int sum = 0;
//
//        for(int i = 0; i <edgeList.size() ; i++){
//            lat = edgeList.get(i).getLat();
//            lng = edgeList.get(i).getLng();
//
//            if((lat1 <= lat && lat <= lat2) && (lng1 <= lng && lng <= lng2)){
//                sum += edgeList.get(i).getSafeVal();
//            }
//        }
//
//        Map<String, Object> bounds = new HashMap<>();   //bound 위경도 변경
//        bounds.put("la",lat1);
//        bounds.put("ea",lng1);
//        bounds.put("ka",lat2);
//        bounds.put("ja",lng2);
//
//        return distanceCalcService.calcDistance(bounds) - sum / distanceCalcService.calcArea(bounds);
//    }

    // 노드 데이터끼리 총 비용을 비교할 수 있도록 Comparator 재정의
    public class NodeComparator implements Comparator<NodeDataDto> {
        public int compare(NodeDataDto nodeFirst, NodeDataDto nodeSecond) {
            if (nodeFirst.getF() < nodeSecond.getF()) return -1;    // F : 거리 + 안전수치
            if (nodeSecond.getF() > nodeFirst.getF()) return 1;
            return 0;
        }
    }

    // 경로 반환하는 메서드
    private List<Long> getPathList(Map<Long, Long> cameFrom, Long destinationId) {
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

    /////////////////////////////////////////////////////////
    // convert decimal degrees to radians
    private double deg2rad(double deg) { return (deg * Math.PI / 180.0); }

    // convert radians to decimal degrees
    private double red2deg(double rad){
        return (rad * 180.0 / Math.PI);
    }

    // 구면 코사인 법칙 사용 거리 계산
    public int calcDistance(double startLng, double startLat, double endLng, double endLat){
        double theta = startLng - endLng;
        double dist = Math.sin(deg2rad(startLat)) * Math.sin(deg2rad(endLat)) + Math.cos(deg2rad(startLat)) * Math.cos(deg2rad(endLat)) * Math.cos(deg2rad(theta));

        dist = Math.acos(dist);
        dist = red2deg(dist);
        dist = dist * 60 * 1.1515 * 1609.344; // meter 단위로 변환
        return (int) (dist);
    }
}