package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EdgeDto {
    private long id;
    private NodeDto startNode;
    private NodeDto endNode;
    private double heuristicValue;
}
