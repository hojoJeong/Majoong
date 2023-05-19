package com.example.majoong.friend.domain;
import com.example.majoong.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;

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
    @Column(name = "friend_name")
    private String friendName;
    private int state;

    @Column(columnDefinition = "BOOLEAN DEFAULT false", name = "is_guardian")
    private boolean isGuardian;

    public Friend(User user, User friend, int state) {
        this.user = user;
        this.friend = friend;
        this.state = state;
        this.isGuardian = false;
    }

    @PrePersist
    public void prePersist() {
        this.friendName = friend.getNickname();
    }


}