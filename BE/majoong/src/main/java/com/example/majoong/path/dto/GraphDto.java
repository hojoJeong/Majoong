package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GraphDto implements Iterable{
    private Map<Long, Map<NodeDataDto, Double>> graph;          // NodeId, Map<노드정보, 가중치>
    private Map<Long, Map<Long, Double>> heuristicMap;          // 그래프에서 노드간의 휴리스틱 값 Map
    private Map<Long, NodeDataDto> nodeIdNodeData;              // 노드 id와 노드 data사이의 Map
    private List<NodeDto> nodeList;
    private List<EdgeDto> edgeList;

    public GraphDto(List<NodeDto> nodeList, List<EdgeDto> edgeList, Map<Long, Map<Long, Double>> heuristicMap){
        this.nodeList = nodeList;
        this.edgeList = edgeList;
        this.heuristicMap = heuristicMap;

        this.graph =new HashMap<>();
        this.nodeIdNodeData = new HashMap<>();

        for (NodeDto n : nodeList){
            addNode(n.getNodeId(), n.getLng(), n.getLat());
        }

        for(EdgeDto e : edgeList){
            addEdge(e.getSourceId(), e.getTargetId(), e.getDistanceVal() - e.getSafeVal());
        }
    }

    public Map<NodeDataDto, Double> edgesFrom (Long nodeId) {
        if (nodeId == null) throw new NullPointerException("The input node should not be null.");
        if (!heuristicMap.containsKey(nodeId)) throw new NoSuchElementException("This node is not a part of hueristic map");
        if (!graph.containsKey(nodeId)) throw new NoSuchElementException("The node should not be null.");

        return Collections.unmodifiableMap(graph.get(nodeId));
    }

    /**
     * Adds a new node to the graph.
     * Internally it creates the nodeData and populates the heuristic map concerning input node into node data.
     *
     * @param nodeId the node to be added
     */
    // 그래프에 새로운 노드 추가. 노드에 대한 heuristic map을 노드 데이터에 채운다
    public void addNode(Long nodeId, double lng, double lat) {
        if (nodeId == null) throw new NullPointerException("The node cannot be null");
        if (!heuristicMap.containsKey(nodeId)) throw new NoSuchElementException("This node is not a part of hueristic map");

        graph.put(nodeId, new HashMap<NodeDataDto, Double>());
        nodeIdNodeData.put(nodeId, new NodeDataDto(nodeId, heuristicMap.get(nodeId), lng, lat));
    }

    /**
     * Adds an edge from source node to destination node.
     * There can only be a single edge from source to node.
     * Adding additional edge would overwrite the value
     *
     * @param nodeIdFirst   the first node to be in the edge    -> 연결할 노드1
     * @param nodeIdSecond  the second node to be second node in the edge   -> 연결할 노드2
     * @param weight        the weight of the edge. -> 노드1 부터 노드2 길이(가중치) -> 우리는 길이 + 가중치가 필요함
     */
    // 출발 노드에서 목적 노드까지 간선 추가
    // 출발 노드로부터 하나의 간선만 있을 수 있다. ???
    // 간선을 추가하면 값을 덮어쓸 수 있다. ???
    public void addEdge(Long nodeIdFirst, Long nodeIdSecond, double weight) {
        if (nodeIdFirst == null || nodeIdSecond == null) throw new NullPointerException("The first nor second node can be null.");

        // 양방향
        if(graph.containsKey(nodeIdFirst) && graph.containsKey(nodeIdSecond)){
            graph.get(nodeIdFirst).put(nodeIdNodeData.get(nodeIdSecond), weight);
            graph.get(nodeIdSecond).put(nodeIdNodeData.get(nodeIdFirst), weight);
        }
    }

    /**
     * The nodedata corresponding to the current nodeId.
     *  현재 노드에 해당하는 노드 데이터
     * @param nodeId    the nodeId to be returned   -> 검색할 노드
     * @return          the nodeData from the
     */
    public NodeDataDto getNodeData (Long nodeId) {
        if (nodeId == null) { throw new NullPointerException("The nodeid should not be empty"); }
        if (!nodeIdNodeData.containsKey(nodeId))  { throw new NoSuchElementException("The nodeId does not exist"); }
        return nodeIdNodeData.get(nodeId);
    }

    @Override public Iterator iterator() {
        return graph.keySet().iterator();
    }
}
