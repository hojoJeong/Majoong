package com.example.majoong.path.service;

import com.example.majoong.exception.SameNodeException;
import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.path.repository.EdgeRepository;
import com.example.majoong.path.repository.NodeRepository;
import com.example.majoong.path.domain.Edge;
import com.example.majoong.path.domain.Node;
import com.example.majoong.path.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.GeoResults;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class RecommendedPathService {

    private GraphDto astarGraph;
    @Autowired
    private NodeRepository nodeRepository;
    @Autowired
    private EdgeRepository edgeRepository;
    private final RedisOperations<String, String> redisOperations;

    private final double CAPTURE_PADDING = 0.00015000000;
    private final double PADDING_RATIO = 3.3; //패딩 조절 비율
    private final int STANDARD_DIST = 254; //padding == CAPTURE_PADDING 일 경우, 가장 깔끔 하게 나온 경로 결과 값의 직선 거리



    public PathInfoDto getRecommendedPath(NodeDto startNode, NodeDto endNode) {

        // 그래프 생성
        createAstarGraph(startNode, endNode);

        // astar 알고리즘
        PathInfoDto recommendedPath = astar(startNode.getNodeId(), endNode.getNodeId(), endNode.getLng(), endNode.getLat());

        return recommendedPath;
    }

    public PathInfoDto testRecommendedPath(double startLng, double startLat, double endLng, double endLat) {

        // 시작점, 도착점과 가장 가까운 노드 탐색
        NodeDto startNode = findNearestNode(startLng, startLat);
        NodeDto endNode = findNearestNode(endLng, endLat);
        System.out.println();
        System.out.println("startNode : " + startNode.getNodeId() + "              endNode : "+  endNode.getNodeId());
        System.out.println();

        // 그래프 생성
        createAstarGraph(startNode, endNode);
        System.out.println("그래프 생성");

        // astar 알고리즘
        PathInfoDto recommendedPath = astar(startNode.getNodeId(), endNode.getNodeId(), endNode.getLng(), endNode.getLat());
        System.out.println("astar 알고리즘");
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
    public GraphDto createAstarGraph(NodeDto startNode, NodeDto endNode) {

        double lng1 = startNode.getLng();
        double lat1 = startNode.getLat();
        double lng2 = endNode.getLng();
        double lat2 = endNode.getLat();

        // startNode와 endNode 기준 영역 안의 모든 node, edge 정보 가져오기
        Map<String,List<?>> nodeEdge = searchNodeEdgeForGraph(lng1, lat1, lng2, lat2);

        List<NodeDto> nodeList = (List<NodeDto>) nodeEdge.get("nodeList");      //영역 안의 모든 노드정보
        List<EdgeDto> edgeList = (List<EdgeDto>) nodeEdge.get("edgeList");      //영역 안의 모든 엣지정보

        Map<Long, Map<Long, Double>> heuristicMap = new HashMap<Long, Map<Long, Double>>(); //휴리스틱 값

        astarGraph = new GraphDto(nodeList, edgeList);
        return new GraphDto(nodeList, edgeList);
    }

    public PathInfoDto astar(Long startId, Long endId, double endLng, double endLat) {

        System.out.println("START : " + startId + "              END : "+  endId);
//        for (EdgeDto edge : astarGraph.getEdgeList()){
//            System.out.println(edge.getEdgeId());
//        }
        System.out.println("edge size : " + astarGraph.getEdgeList().size());


        /**
         * http://stackoverflow.com/questions/20344041/why-does-priority-queue-has-default-initial-capacity-of-11
         */
        // 우선선위 큐(초기 용량, 비교수단 Comparator)
//        final Queue<NodeDataDto> openQueue = new PriorityQueue<NodeDataDto>(11, new NodeComparator());
        // 초기값을 노드의 크기로 설정
//        final Queue<NodeDataDto> openQueue = new PriorityQueue<NodeDataDto>(astarGraph.getNodeList().size(), new NodeComparator());
        // 우선순위 큐
        final PriorityQueue<NodeDataDto> openQueue = new PriorityQueue<NodeDataDto>(Comparator.comparingDouble(nodeDataDto -> nodeDataDto.getF()));

        // 그래프의 소스노드 부터 시작
        NodeDataDto sourceNodeDataDto = astarGraph.getNodeData(startId);
        double nodeLng1 = sourceNodeDataDto.getLng();
        double nodeLat1 = sourceNodeDataDto.getLat();

        System.out.println("시작 : " + nodeLng1 + ", " + nodeLat1 + " / 도착 : " + endLng + ", " + endLat);

        sourceNodeDataDto.setG(0); // 출발지점 0
        sourceNodeDataDto.calcF(endId, endLng, endLat); // 도착지까지의 총 비용 계산
        openQueue.add(sourceNodeDataDto); // 출발 노드 큐에 삽입

        // key: 노드, value : 부모 노드   -> 키에 해당하는 노드는 value에 해당하는 노드를 거쳐서 왔다는 뜻
        final Map<Long, Long> cameFrom = new HashMap<Long, Long>(); // 경로 Map
        final Set<Long> closedList = new HashSet<>(); // 닫힌 목록 -> 더 이상 볼 필요 없는 목록

        // 반환값
        PathInfoDto result = new PathInfoDto();

        // 큐 : 열린 목록
        // 큐가 비기 전 까지 무한 반복 -> 큐가 빈거면 경로가 없다는 뜻
        while (!openQueue.isEmpty()) {

            final NodeDataDto currentNode = openQueue.poll();  // 큐에서 하나 poll

            // 도착지 노드 발견하면 경로에 추가하고 종료
            if (currentNode.getNodeId().equals(endId)) {
                List<Long> pathList = getPathList(cameFrom, endId);
                List<LocationDto> pointList = new ArrayList<>();
                double distance = 0.0;
                for(long id : pathList){
                    Node resultNode = nodeRepository.findById(id).get();
                    double nodeLng2 = resultNode.getLng();
                    double nodeLat2 = resultNode.getLat();
                    pointList.add(new LocationDto(nodeLng2, nodeLat2));
                    distance += calcDistance(nodeLng1, nodeLat1, nodeLng2, nodeLat2);

                    nodeLng1 = nodeLng2;
                    nodeLat1 = nodeLat2;
                }
                result.setPoint(pointList);
                result.setDistance((int) distance);
                result.setTime((int)(distance/1000/5*60));

                for (long id : pathList){
                    System.out.println(id);
                }

                return result;
            }

            // poll한 노드 닫힌 목록에 추가
            closedList.add(currentNode.getNodeId());

            // poll한 노드의 인접 노드를 하나씩 뽑아서 진행
            for (Map.Entry<NodeDataDto, Double> neighborEntry : astarGraph.edgesFrom(currentNode.getNodeId()).entrySet()) {
                // 인접 노드
                NodeDataDto neighborNode = neighborEntry.getKey();

                // 닫힌 목록에 있으면 볼 필요 없음
                if (closedList.contains(neighborNode.getNodeId())) continue;

                double distanceBetweenTwoNodes = neighborEntry.getValue();  // 두 노드 사이의 비용
                double tentativeG = distanceBetweenTwoNodes + currentNode.getG();  // 두 노드 사이의 비용 + poll한 노드의 G값

                // poll한 노드 거쳐서 온 G값이 더 작으면 G값 변경
                if (tentativeG < neighborNode.getG()) {
                    neighborNode.setG(tentativeG);
                    neighborNode.calcF(endId, endLng, endLat);

                    // 경로 map에 추가 -> 내가 어디서 왔는가 ( 부모 노드 입력 )
                    cameFrom.put(neighborNode.getNodeId(), currentNode.getNodeId());
                    // 큐에 이웃이 포함 안되어 있으면 추가
                    if (!openQueue.contains(neighborNode)) {
                        openQueue.add(neighborNode);
                    }
                }
            }
            System.out.println("currentNode : " + currentNode.getNodeId());
        }
        log.info("안전 경로를 찾을 수 없습니다");
        return null;
    }

    public double calcHeuristicVal(double lng1, double lat1, double lng2, double lat2, List<EdgeDto> edgeList){

        // 1번 : 왼쪽아래, 2번 : 오른쪽위 로 오도록 세팅
        if(!(lat1 < lat2)){
            double temp = lat1;
            lat1 = lat2;
            lat2 = temp;
        }
        if(!(lng1 < lng2)){
            double temp = lng1;
            lng1= lng2;
            lng2=temp;
        }

        int sum = 0;

        for(EdgeDto edge : edgeList){
            double centerLng = edge.getCenterLng();
            double centerLat = edge.getCenterLat();

            if((lat1 <= centerLat && centerLat <= lat2) && (lng1 <= centerLng && centerLng <= lng2)){
                sum += edge.getSafety();
            }
        }

        double safetyRate = calcDistance(lng1, lat1, lng2, lat2) - sum / calcArea(lng1, lat1, lng2, lat2);

        return safetyRate;
    }

    // 노드 데이터끼리 총 비용을 비교할 수 있도록 Comparator 재정의
    public class NodeComparator implements Comparator<NodeDataDto> {
        public int compare(NodeDataDto nodeFirst, NodeDataDto nodeSecond) {
            if (nodeFirst.getF() < nodeSecond.getF()) return -1;    // F : 거리 + 안전수치
            if (nodeSecond.getF() > nodeFirst.getF()) return 1;
            return 0;
        }
    }

    // 경로 반환하는 메서드
    private List<Long> getPathList(Map<Long, Long> cameFrom, Long endId) {
        // assert boolean 식;       boolean 식이 true인 경우에만 프로그램이 실행
        assert cameFrom != null;
        assert endId != null;

        final List<Long> pathList = new ArrayList<>();
        pathList.add(endId);
        while (cameFrom.containsKey(endId)) {
            endId = cameFrom.get(endId);
            pathList.add(endId);
        }
        Collections.reverse(pathList);
        return pathList;
    }

    public Map<String,List<?>> searchNodeEdgeForGraph(double lng1, double lat1, double lng2, double lat2){

//        double padding = calcPadding(lng1, lat1, lng2, lat2)*CAPTURE_PADDING;

        if((lat1>lat2)){
            double temp = lat1;
            lat1 = lat2;
            lat2 = temp;
        }
        if((lng1>lng2)){
            double temp = lng1;
            lng1 = lng2;
            lng2 =temp;
        }

//        lng1 -= padding;
//        lat1 -= padding;
//        lng2 += padding;
//        lat2 += padding;

        double paddingLng = 0.0011;
        double paddingLat = 0.0009;

        lng1 -= paddingLng;
        lat1 -= paddingLat;
        lng2 += paddingLng;
        lat2 += paddingLat;

        List<Node> nodes = nodeRepository.findNodesByArea(lng1, lat1, lng2, lat2);
        List<NodeDto> nodeList = new ArrayList<>();
        for (Node node : nodes) {
            NodeDto nodeDto = new NodeDto(node.getNodeId(), node.getLng(), node.getLat());
            nodeList.add(nodeDto);
        }

        List<Edge> edges = edgeRepository.findEdgesByArea(lng1, lat1, lng2, lat2);
        List<EdgeDto> edgeList = new ArrayList<>();
        for (Edge edge : edges) {
            EdgeDto edgeDto = new EdgeDto(edge.getEdgeId(),
                    edge.getSourceId(), edge.getSourceLng(), edge.getSourceLat(),
                    edge.getTargetId(), edge.getTargetLng(), edge.getTargetLat(),
                    edge.getSafety(), edge.getDistance(), edge.getCenterLng(), edge.getCenterLat());
            edgeList.add(edgeDto);
        }

        // 불러온 노드와 엣지가 유효한지 검사
//        boolean startFlag = false;
//        boolean endFlag = false;
//
//        List<EdgeDto> checkedEdgeList = new ArrayList<>();
//
//        for(EdgeDto edge : edgeList){
//            for(NodeDto node : nodeList){
//
//                if(node.getNodeId() == edge.getSourceId()) startFlag = true;
//                if(node.getNodeId() == edge.getTargetId()) endFlag = true;
//            }
//            if (startFlag && endFlag) {
//                checkedEdgeList.add(edge);
//            }
//            startFlag = false;
//            endFlag = false;
//        }

        Map<String, List<? extends Object>> result= new HashMap<>();

        result.put("nodeList", nodeList);
        result.put("edgeList", edgeList);
//        result.put("edgeList", checkedEdgeList);

        return result;
    }

    @Transactional
    public void setEdgeSafety() {

        List<Edge> edgeList = edgeRepository.findEdgeList();

        for(Edge edge : edgeList){
            Long edgeId = edge.getEdgeId();
            double centerLng = edge.getCenterLng();
            double centerLat = edge.getCenterLat();
            int distance = (int) Math.round(edge.getDistance());
            if (distance <= 1) distance = 1;

//            System.out.println();
//            System.out.println(edgeId);
//            System.out.println(centerLng);
//            System.out.println(centerLat);
//            System.out.println(distance);
//            System.out.println();

            RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates();
            GeoResults<RedisGeoCommands.GeoLocation<String>> policeResult = redisOperations.opsForGeo()
                    .radius("police", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            GeoResults<RedisGeoCommands.GeoLocation<String>> safeRoadResult = redisOperations.opsForGeo()
                    .radius("saferoad", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            GeoResults<RedisGeoCommands.GeoLocation<String>> storeResult = redisOperations.opsForGeo()
                    .radius("store", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            GeoResults<RedisGeoCommands.GeoLocation<String>> cctvResult = redisOperations.opsForGeo()
                    .radius("cctv", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            GeoResults<RedisGeoCommands.GeoLocation<String>> bellResult = redisOperations.opsForGeo()
                    .radius("bell", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            GeoResults<RedisGeoCommands.GeoLocation<String>> lampResult = redisOperations.opsForGeo()
                    .radius("lamp", new Circle(new Point(centerLng, centerLat), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

            int policeNum = policeResult.getContent().size();
            int safeRoadNum = safeRoadResult.getContent().size();
            int storeNum = storeResult.getContent().size();
            int cctvNum = cctvResult.getContent().size();
            int bellNum = bellResult.getContent().size();
            int lampNum = lampResult.getContent().size();

            /*
            // 안전 시설물 점수 (전체 : 25)
            경찰서 : 10
            편의점 : 5
            cctv : 5
            안전귀갓길 : 3
            비상벨 : 1
            가로등 : 1
             */
            int policeVal = 10;
            int safeRoadVal = 3;
            int storeVal = 5;
            int cctvVal = 5;
            int bellVal = 1;
            int lampVal = 1;

            if (policeNum == 0) policeVal = 0;
            if (safeRoadNum == 0) safeRoadVal = 0;
            if (storeNum == 0) storeVal = 0;
            if (cctvNum == 0) cctvVal = 0;
            if (bellNum == 0) bellVal = 0;
            if (lampNum == 0) lampVal = 0;

            int safety = policeVal + safeRoadVal + storeVal + cctvVal + bellVal + lampVal;

            System.out.println();
            System.out.println(safety);
            System.out.println();

            edge.setSafety(safety);
            edgeRepository.save(edge);
        }
    }


    // convert decimal degrees to radians
    private double deg2rad(double deg) { return (deg * Math.PI / 180.0); }

    // convert radians to decimal degrees
    private double red2deg(double rad){
        return (rad * 180.0 / Math.PI);
    }

    // 두 지점 사이의 각도 구하는 메서드
    private double calcDegree(double startLng, double startLat, double endLng, double endLat){
        double angle = red2deg(Math.atan2(startLat - endLat, startLng - endLng));

        if(angle < 0) angle += 360;

        return angle;
    }

    // 구면 코사인 법칙 사용 거리 계산
    public double calcDistance(double startLng, double startLat, double endLng, double endLat){
        double theta = startLng - endLng;
        double distance = Math.sin(deg2rad(startLat)) * Math.sin(deg2rad(endLat)) + Math.cos(deg2rad(startLat)) * Math.cos(deg2rad(endLat)) * Math.cos(deg2rad(theta));

        distance = Math.acos(distance);
        distance = red2deg(distance);
        distance = distance * 60 * 1.1515 * 1609.344; // meter 단위로 변환
        return distance;
    }

    // 두 점을 대각선으로 하는 사각형 넓이
    public double calcArea(double startLng, double startLat, double endLng, double endLat){

        double straightDistance = calcDistance(startLng, startLat, endLng, endLat);

        double degree = calcDegree(startLng, startLat, endLng, endLat);

        // 가로 곱하기 세로 리턴
        return straightDistance * Math.cos(degree) * straightDistance * Math.sin(degree);
    }

    private double calcPadding(double lng1, double lat1, double lng2, double lat2){

        double dist = calcDistance(lng1, lat1, lng2, lat2);

        return dist*PADDING_RATIO/STANDARD_DIST;
    }
}