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
public class ShortGraphDto implements Iterable{
    private Map<Long, Map<NodeDataDto, Double>> graph;          // NodeId, Map<노드정보, 가중치>
    private Map<Long, NodeDataDto> nodeIdNodeData;              // 노드 id와 노드 data의 Map
    private List<NodeDto> nodeList;
    private List<EdgeDto> edgeList;

    public ShortGraphDto(List<NodeDto> nodeList, List<EdgeDto> edgeList){
        this.nodeList = nodeList;
        this.edgeList = edgeList;

        this.graph = new LinkedHashMap<>();
        this.nodeIdNodeData = new LinkedHashMap<>();

        for (NodeDto n : nodeList){
            addNode(n.getNodeId(), n.getLng(), n.getLat());
        }

        for(EdgeDto e : edgeList){
            addEdge(e.getSourceId(), e.getTargetId(), e.getDistance());
//            addEdge(e.getSourceId(), e.getTargetId(), e.getDistance());
        }
    }

    public Map<NodeDataDto, Double> edgesFrom (Long nodeId) {
        if (nodeId == null) throw new NullPointerException("The input node should not be null.");
        if (!graph.containsKey(nodeId)) throw new NoSuchElementException("The node should not be null.");

        return Collections.unmodifiableMap(graph.get(nodeId)); // 읽기 전용으로 반환
    }


    public void addNode(Long nodeId, double lng, double lat) {
        if (nodeId == null) throw new NullPointerException("The node cannot be null");

        graph.put(nodeId, new LinkedHashMap<NodeDataDto, Double>());
        nodeIdNodeData.put(nodeId, new NodeDataDto(nodeId, lng, lat));
    }


    public void addEdge(Long nodeIdFirst, Long nodeIdSecond, double weight) {
        if (nodeIdFirst == null || nodeIdSecond == null) throw new NullPointerException("The first nor second node can be null.");

        // 양방향
        if(graph.containsKey(nodeIdFirst) && graph.containsKey(nodeIdSecond)){
            graph.get(nodeIdFirst).put(nodeIdNodeData.get(nodeIdSecond), weight);
            graph.get(nodeIdSecond).put(nodeIdNodeData.get(nodeIdFirst), weight);
        }
    }

    public NodeDataDto getNodeData (Long nodeId) {
        if (nodeId == null) { throw new NullPointerException("The nodeid should not be empty"); }
        if (!nodeIdNodeData.containsKey(nodeId))  { throw new NoSuchElementException("The nodeId does not exist"); }
        return nodeIdNodeData.get(nodeId);
    }

    @Override public Iterator iterator() {
        return graph.keySet().iterator();
    }
}
