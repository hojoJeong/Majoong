package com.example.majoong.user.service;

import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.Favorite;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.FavoriteDto;
import com.example.majoong.user.dto.FavoriteResponseDto;
import com.example.majoong.user.repository.FavoriteRepository;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final JwtTool jwtTool;

    public void addFavorite(HttpServletRequest request, FavoriteDto favoriteDto){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        Favorite favorite = new Favorite();
        favorite.setAddress(favoriteDto.getAddress());
        favorite.setLocationName(favoriteDto.getLocationName());
        favorite.setUser(user);
        favoriteRepository.save(favorite);
    }

    public List<FavoriteResponseDto> getFavorites(HttpServletRequest request){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        List<Favorite> favorites= favoriteRepository.findAllByUser(user);
        List<FavoriteResponseDto> result = new ArrayList<>();
        for (Favorite favorite: favorites){
            FavoriteResponseDto res = new FavoriteResponseDto();
            res.setId(favorite.getId());
            res.setAddress(favorite.getAddress());
            res.setLocationName(favorite.getLocationName());
            result.add(res);
        }
    return result;
    }
    public void deleteFavorite(HttpServletRequest request, FavoriteDto favorite){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        Favorite favoriteInfo = favoriteRepository.findByUserAndAddressAndLocationName(user,favorite.getAddress(), favorite.getLocationName());
        favoriteRepository.delete(favoriteInfo);
    }
}
