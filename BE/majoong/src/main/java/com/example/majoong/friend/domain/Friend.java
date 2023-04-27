package com.example.majoong.friend.domain;
import com.example.majoong.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import javax.persistence.*;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Entity
@Table(name = "friend")
public class Friend {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @ManyToOne
    @JoinColumn(name = "friend_id")
    private User friend;
    private String friendName;
    private int state;

    public Friend(User user, User friend, int state) {
        this.user = user;
        this.friend = friend;
        this.state = state;
    }

    @PrePersist
    public void prePersist() {
        this.friendName = friend.getNickname();}


}