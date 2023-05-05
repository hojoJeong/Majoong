import 'package:flutter/material.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/util/logger.dart';

class FavoriteWidget extends StatelessWidget {
  final String name, address;

  const FavoriteWidget({Key? key, required this.name, required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        logger.d('선택한 검색 키워드 : $name, $address');
      },
      child: Container(
        width: 150,
        height: 100,
        child: Row(
          children: [
            Image(
              image: AssetImage('res/icon_favorite.png'),
              width: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  width: 100,
                  child: Text(
                    address,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
