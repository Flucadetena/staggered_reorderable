import 'package:flutter/material.dart';
import 'dart:math';

import 'item_model.dart';

/// guoshijun created this file at 2022/5/5 10:05 上午
///
/// 渲染瀑布流及支持拖拽布局

/// 最大高度
double maxContainerHeight = 0.0;

/// 最大宽度
double maxContainerWidth = 0.0;

/// 单元格大小
double itemCell = 0.0;

class StaggeredReorderableView extends StatefulWidget {
  /// 布局方向[Axis.vertical] 和[Axis.horizontal]。
  /// 默认[Axis.vertical]，布局为垂直布局。
  final Axis scrollDirection;

  /// 动画时间，默认[Duration(milliseconds: 300)]。
  final Duration duration;

  /// 防抖时间，默认[Duration(milliseconds: 100)]
  final Duration antiShakeDuration;

  /// 拖拽后变换规则，[true]为交换，[false]为插入
  final bool collation;

  /// 布局的子项
  /// [ReorderableItem.id]不允许存在重复值
  /// [ReorderableItem.index]不允许存在重复值
  final List<ReorderableItem> children;

  /// 每行个数
  final int columnNum;

  /// 边距
  final double spacing;

  /// 是否允许拖拽
  final bool canDrag;

  /// 布局区域高度，仅在[Axis.horizontal]时生效
  final double containerHeight;

  /// The background [Color] of the container. Defaults to [Colors.grey]
  final Color backgroundColor;

  /// The background [Color] of the container while being dragged. Defaults to [Colors.white]
  final Color onDragBackgroundColor;

  /// 创建一个可拖动的不规则图形瀑布流.
  ///
  /// [canDrag] : 控制是否允许拖动,默认为`true`.
  ///
  /// [columnNum] : 控制每行([Axis.vertical])/每列([Axis.horizontal])展示的基本单元数量,默认为每行.
  ///
  /// [scrollDirection] : 控制排版方向,默认为[Axis.vertical].
  ///
  /// [duration] : 每次交换的动画持续时间,默认0.3s.
  ///
  /// [antiShakeDuration] : 防抖时间,默认0.1s.
  ///
  /// [collation] : 拖拽交换规则,[true]为交换，[false]为插入.
  ///
  /// [containerHeight] : 当 [scrollDirection] 选择 [Axis.horizontal] 时,才会生效.

  final Function()? onDragStarted;
  final Function()? onDraggableCanceled;
  final Function()? onDragCompleted;
  final Function()? onWillAccept;
  final Function()? onLeave;
  final Function(int idx, String id)? onTap;

  const StaggeredReorderableView({
    Key? key,
    required this.children,
    this.spacing = 8,
    this.columnNum = 3,
    // TODO: Fix spacing error that doesn't center objects. The problem is that it leaves the spacing in the last position of a row, making all widgets align "start" in the row
    this.canDrag = true,
    this.collation = false,
    this.containerHeight = 600.0,
    this.backgroundColor = Colors.transparent,
    this.onDragBackgroundColor = Colors.white10,
    this.scrollDirection = Axis.vertical,
    this.duration = const Duration(milliseconds: 300),
    this.antiShakeDuration = const Duration(milliseconds: 100),
    this.onDragStarted,
    this.onDraggableCanceled,
    this.onDragCompleted,
    this.onWillAccept,
    this.onLeave,
    this.onTap,
  }) : super(key: key);

  @override
  _StaggeredReorderableViewState createState() => _StaggeredReorderableViewState();
}

class _StaggeredReorderableViewState extends State<StaggeredReorderableView> with SingleTickerProviderStateMixin {
  /// 正在拖拽的item
  int dragItem = -1;

  /// 当前moveIndex
  int nowMoveIndex = -1;

  /// 当前接收的位置
  int nowAcceptIndex = -1;

  /// 拖拽进度
  double process = 0.0;

  List<ReorderableItem> children = [];

  List<ReorderableItem> itemChangeAll = [];

  late AnimationController _controller;

  @override
  void initState() {
    children = widget.children;
    _controller = AnimationController(
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        process = _controller.value;
        if (_controller.isCompleted) {
          changeItemChangeAllToItemAll();
          _controller.reset();
        }
        setState(() {});
      });
    super.initState();
  }

  /// 防抖处理
  void antiShakeProcessing(moveIndex, toIndex) {
    nowMoveIndex = moveIndex;
    nowAcceptIndex = toIndex;
    Future.delayed(widget.antiShakeDuration).then((value) {
      if (nowMoveIndex == moveIndex && nowAcceptIndex == toIndex) {
        nowMoveIndex = -1;
        nowAcceptIndex = -1;
        if (!_controller.isAnimating) {
          exchangeItem(moveIndex, toIndex);
          _controller.forward();
        } else {
          _controller.reset();
          exchangeItem(moveIndex, toIndex);
          _controller.forward();
        }
      }
    });
  }

  /// 交换数据
  void exchangeItem(moveIndex, toIndex) {
    if (itemChangeAll.isEmpty) {
      for (ReorderableItem element in children) {
        itemChangeAll.add(element);
      }
    }
    if (!widget.collation) {
      setState(() {
        ReorderableItem moveData = itemChangeAll.firstWhere((element) => element.index == moveIndex);
        int reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        int receiveIndex = itemChangeAll.indexWhere((element) => element.index == toIndex);
        if (receiveIndex >= reIndex) receiveIndex += 1;
        itemChangeAll.insert(receiveIndex, moveData);
      });
    } else {
      // print("初始状态");
      // itemChangeAll.forEach((element) {
      //   print(element.toString());
      // });
      setState(() {
        ReorderableItem moveData = itemChangeAll.firstWhere((element) => element.index == moveIndex);
        int reIndex = itemChangeAll.indexOf(moveData);
        itemChangeAll.remove(moveData);
        int receiveIndex = itemChangeAll.indexWhere((element) => element.index == toIndex);
        // if (receiveIndex >= reIndex) receiveIndex += 1;
        itemChangeAll.insert(receiveIndex, moveData);
        ReorderableItem receiveData = itemChangeAll.removeAt(receiveIndex + 1);
        itemChangeAll.insert(reIndex, receiveData);
      });
      // print("交换后状态");
      // itemChangeAll.forEach((element) {
      //   print(element.toString());
      // });
    }
  }

  changeItemChangeAllToItemAll() async {
    children = itemChangeAll;
    itemChangeAll = [];
  }

  /// 子项
  Widget generateItem(int index) {
    return LayoutId(
      id: children[index].id!,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(index, children[index].id!),
        child: widget.canDrag
            ? LongPressDraggable(
                data: children[index].index,
                childWhenDragging: null,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: children[index].crossAxisCellCount! * itemCell,
                    height: children[index].mainAxisCellCount! * itemCell,
                    color: widget.onDragBackgroundColor,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: children[index].child,
                      ),
                    ),
                  ),
                ),
                onDragStarted: () {
                  widget.onDragStarted?.call();
                  // print('=== onDragStarted');
                  dragItem = children[index].index!;
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  widget.onDraggableCanceled?.call();
                  // print('=== onDraggableCanceled');
                },
                onDragCompleted: () {
                  widget.onDragCompleted?.call();
                  // print('=== onDragCompleted');
                  dragItem = -1;
                  nowAcceptIndex = -1;
                  nowMoveIndex = -1;
                },
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: children[index].crossAxisCellCount! * itemCell,
                      height: children[index].mainAxisCellCount! * itemCell,
                      color: widget.backgroundColor,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(child: children[index].child),
                      ),
                    );
                  },
                  onWillAccept: (moveData) {
                    widget.onWillAccept?.call();
                    // print('=== onWillAccept: $moveData ==> ${itemAll[index].index}');
                    bool accept = moveData != null;
                    if (accept && dragItem != children[index].index! && children[index].index != moveData) {
                      antiShakeProcessing(moveData, children[index].index);
                    }
                    return accept;
                  },
                  onLeave: (moveData) {
                    widget.onLeave?.call();
                    // print('=== onLeave: $moveData ==> ${itemAll[index].index}');
                    if (moveData == nowMoveIndex) {
                      nowMoveIndex = -1;
                    }
                    if (children[index].index == nowAcceptIndex) {
                      nowAcceptIndex = -1;
                    }
                  },
                ),
              )
            : Container(
                width: children[index].crossAxisCellCount! * itemCell,
                height: children[index].mainAxisCellCount! * itemCell,
                color: widget.backgroundColor,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(child: children[index].child),
                ),
              ),
      ),
    );
  }

  List<Widget> generateList() {
    List<Widget> list = [];
    for (int index = 0; index < children.length; index++) {
      list.add(generateItem(index));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (maxContainerWidth == 0.0) {
      maxContainerWidth = MediaQuery.of(context).size.width;
    }
    if (maxContainerHeight == 0.0) {
      maxContainerHeight = MediaQuery.of(context).size.height;
    }
    return SingleChildScrollView(
      scrollDirection: widget.scrollDirection,
      child: SizedBox(
        height: widget.scrollDirection == Axis.vertical ? maxContainerHeight : widget.containerHeight,
        width: maxContainerWidth,
        child: CustomMultiChildLayout(
          delegate: widget.scrollDirection == Axis.vertical
              ? ProxyVerticalClass(children, itemChangeAll, process, widget.columnNum, widget.spacing)
              : ProxyHorizontalClass(
                  children, itemChangeAll, process, widget.columnNum, widget.spacing, widget.containerHeight),
          children: generateList(),
        ),
      ),
    );
  }
}

/// [Axis.vertical]
class ProxyVerticalClass extends MultiChildLayoutDelegate {
  final List<ReorderableItem> itemAll;
  final List<ReorderableItem> itemChangeAll;
  final double process;
  final int columnNum;
  final double padding;

  ProxyVerticalClass(this.itemAll, this.itemChangeAll, this.process, this.columnNum, this.padding) {
    // 累计每列的高度
    columnH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    columnLastH = List.generate(columnNum, (index) {
      return 0.0;
    });
  }

  late List columnH;
  late List columnLastH;

  /// 判断当前行是否可以存放此widget,
  /// 查到后返回index > 0
  /// 未查到返回index = -1
  int checkNowRow(Size size, double itemCell, List columnH, List columnLastH) {
    int insertIndex = -1;
    // 找到最大值
    double maxHeight =
        columnH.fold(columnH[0], (previousValue, element) => previousValue > element ? previousValue : element);

    // 判断本行是否都已经按行放满
    for (int indexX = 0; indexX < columnH.length; indexX++) {
      if (columnH[indexX] - columnLastH[indexX] < itemCell) {
        // 判断当前点是否符合长度
        int length = size.width ~/ itemCell;
        if (columnH.length - indexX >= length) {
          insertIndex = indexX;
          for (int indexY = 0; indexY < length; indexY++) {
            if (columnH[indexY + indexX] - columnLastH[indexY + indexX] < itemCell) {
            } else if (maxHeight - columnH[indexY + indexX] < size.height) {
              insertIndex = -1;
              break;
            }
          }
          return insertIndex;
        }
      }
    }

    // 判断本行是否存在可以放当前widget的空隙
    for (int indexX = 0; indexX < columnH.length; indexX++) {
      // print("$indexX: $maxHeight - ${columnH[indexX]} >= ${size.height}");
      if (maxHeight - columnH[indexX] >= size.height) {
        // 判断当前点是否符合长度
        int length = size.width ~/ itemCell;
        if (columnH.length - indexX >= length) {
          insertIndex = indexX;
          for (int indexY = 0; indexY < length; indexY++) {
            if (columnH[indexY + indexX] - columnLastH[indexY + indexX] < itemCell) {
            } else if (maxHeight - columnH[indexY + indexX] < size.height) {
              insertIndex = -1;
              break;
            }
          }
          break;
        }
      }
    }
    // print("获取到的值：$insertIndex, 上一行高度：$columnLastH, 本行高度：$columnH");
    if (insertIndex == -1) {
      updateColumnH(columnH, columnLastH);
    }
    return insertIndex;
  }

  /// 修改columnH
  /// 将上一行高度更新成当前行的最高高度
  void updateColumnH(List columnH, List columnLastH) {
    double maxHeight =
        columnH.fold(columnH[0], (previousValue, element) => previousValue > element ? previousValue : element);
    for (int index = 0; index < columnH.length; index++) {
      columnH[index] = maxHeight;
      columnLastH[index] = maxHeight;
    }
  }

  /// 实际计算每个item位置，
  /// 返回所有所有item信息
  List<ItemPosition> calculateFormLayout(List<ReorderableItem> itemAll) {
    List<ItemPosition> calculateItemPosition = [];
    // x轴偏移量
    double offsetX = 0;

    // 当前行的index
    int nowRowIndex = 0;
    for (int i = 0; i < itemAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = layoutChild(
          itemAll[i].id!,
          BoxConstraints(
              minWidth: itemCell * (itemAll[i].crossAxisCellCount!) + ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              maxWidth: itemCell * (itemAll[i].crossAxisCellCount!) + ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              minHeight: itemCell * (itemAll[i].mainAxisCellCount!) + ((itemAll[i].mainAxisCellCount!) - 1) * padding,
              maxHeight: itemCell * (itemAll[i].mainAxisCellCount!) + ((itemAll[i].mainAxisCellCount!) - 1) * padding));

      if (true) {
        int insertIndex = checkNowRow(itemSize, itemCell, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell + (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemAll[i].id!, Offset(offsetX + padding * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += padding +
          itemCell * (itemAll[i].crossAxisCellCount ?? 1) +
          ((itemAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (int c = 0; c < itemAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + padding;
        if (nowRowIndex < columnNum - 1) {
          nowRowIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }

  /// 放置item
  void positionItem(List<ItemPosition> itemPositionList) {
    for (ItemPosition element in itemPositionList) {
      /// 放置当前widget
      positionChild(element.id, element.offset);
    }
    // 刷新最高高度
    double tempHeight = 0.0;
    for (var element in columnH) {
      tempHeight = max(tempHeight, element);
    }
    if (tempHeight != 0.0) {
      maxContainerHeight = tempHeight;
    }
    columnH.clear();
    columnLastH.clear();
  }

  /// 计算偏移量
  List<ItemPosition> calculateOffset(List<ItemPosition> itemPositionList, List<ItemPosition> dragItemPosition) {
    List<ItemPosition> item = [];
    for (int index = 0; index < itemAll.length; index++) {
      Offset offset = dragItemPosition[index].transform(itemPositionList[index]);
      item.add(ItemPosition(
          itemPositionList[index].id,
          Offset(itemPositionList[index].offset.dx + offset.dx * process,
              itemPositionList[index].offset.dy + offset.dy * process)));
    }
    return item;
  }

  @override
  void performLayout(Size size) {
    double actualWidth = size.width - (columnNum + 1) * padding;

    itemCell = actualWidth / columnNum;

    List<ItemPosition> itemPositionList = calculateFormLayout(itemAll);

    if (itemChangeAll.isEmpty) {
      positionItem(itemPositionList);
    } else {
      List<ItemPosition> dragItemPosition = calculateDragFormLayout(itemChangeAll);
      List<ItemPosition> item = calculateOffset(itemPositionList, dragItemPosition);
      positionItem(item);
    }
  }

  @override
  bool shouldRelayout(covariant ProxyVerticalClass oldDelegate) {
    if (itemChangeAll.isEmpty || oldDelegate.itemChangeAll.isEmpty) {
      return false;
    }
    for (int index = 0; index < itemAll.length; index++) {
      bool itemEqual = oldDelegate.itemAll[index].compare(itemAll[index]);
      if (!itemEqual) {
        return true;
      }
      bool itemChangeEqual = oldDelegate.itemChangeAll[index].compare(itemChangeAll[index]);
      if (!itemChangeEqual) {
        return true;
      }
      bool itemCompareEqual = oldDelegate.itemAll[index].compare(itemChangeAll[index]);
      if (!itemCompareEqual) {
        return true;
      }
    }
    if (oldDelegate.process != process) {
      return true;
    }
    return false;
  }

  /// 计算拖拽排序后的item位置(拖拽)
  List<ItemPosition> calculateDragFormLayout(List<ReorderableItem> itemChangeAll) {
    List<ItemPosition> calculateItemPosition = [];

    // 累计每列的高度
    List columnH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    List columnLastH = List.generate(columnNum, (index) {
      return 0.0;
    });

    // x轴偏移量
    double offsetX = 0;

    // 当前行的index
    int nowRowIndex = 0;
    for (int i = 0; i < itemChangeAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = getSize(BoxConstraints(
          minWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          maxWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          minHeight:
              itemCell * (itemChangeAll[i].mainAxisCellCount!) + ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding,
          maxHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding));

      // 当前widget横向排布后越界处理
      if (true) {
        int insertIndex = checkNowRow(itemSize, itemCell, columnH, columnLastH);
        if (insertIndex == -1) {
          offsetX = 0;
          nowRowIndex = 0;
        } else {
          offsetX = insertIndex * itemCell + (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowRowIndex = insertIndex;
        }
      }

      calculateItemPosition
          .add(ItemPosition(itemChangeAll[i].id!, Offset(offsetX + padding * 0.5, columnH[nowRowIndex])));

      // 修改x轴偏移量
      offsetX += padding +
          itemCell * (itemChangeAll[i].crossAxisCellCount ?? 1) +
          ((itemChangeAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (int c = 0; c < itemChangeAll[i].crossAxisCellCount!; c++) {
        columnH[nowRowIndex] += itemSize.height + padding;
        if (nowRowIndex < columnNum - 1) {
          nowRowIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }
}

/// [Axis.horizontal]
class ProxyHorizontalClass extends MultiChildLayoutDelegate {
  final List<ReorderableItem> itemAll;
  final List<ReorderableItem> itemChangeAll;
  final double process;
  final int columnNum;
  final double padding;
  final double containerHeight;

  ProxyHorizontalClass(
      this.itemAll, this.itemChangeAll, this.process, this.columnNum, this.padding, this.containerHeight) {
    // 累计每行的宽度
    rowW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每行的宽度
    rowLastW = List.generate(columnNum, (index) {
      return 0.0;
    });

    itemCell = containerHeight / columnNum;
  }

  late List rowW;
  late List rowLastW;

  /// 修改rowW
  /// 将上一行宽度更新成当前行的最大宽度
  void updateRowW(List rowW, List rowLastW) {
    double maxHeight =
        rowW.fold(rowW[0], (previousValue, element) => previousValue > element ? previousValue : element);
    for (int index = 0; index < rowW.length; index++) {
      rowW[index] = maxHeight;
      rowLastW[index] = maxHeight;
    }
  }

  /// 判断当前列是否可以存放此widget,
  /// 查到后返回index > 0
  /// 未查到返回index = -1
  int checkNowColumn(Size size, double itemCell, List rowW, List rowLastW) {
    int insertIndex = -1;
    // 找到最大值
    double maxWidth = rowW.fold(rowW[0], (previousValue, element) => previousValue > element ? previousValue : element);

    // 判断本列是否都已经按列放满
    for (int indexY = 0; indexY < rowW.length; indexY++) {
      if (rowW[indexY] - rowLastW[indexY] < itemCell) {
        // 判断当前点是否符合长度
        int length = size.height ~/ itemCell;
        if (rowW.length - indexY >= length) {
          insertIndex = indexY;
          for (int indexX = 0; indexX < length; indexX++) {
            if (rowW[indexY + indexX] - rowLastW[indexY + indexX] < itemCell) {
            } else if (maxWidth - rowW[indexY + indexX] < size.width) {
              insertIndex = -1;
              break;
            }
          }
          return insertIndex;
        }
      }
    }

    // 判断本列是否存在可以放当前widget的空隙
    for (int indexY = 0; indexY < rowW.length; indexY++) {
      // print("$indexX: $maxHeight - ${columnH[indexX]} >= ${size.height}");
      if (maxWidth - rowW[indexY] >= size.width) {
        // 判断当前点是否符合长度
        int length = size.height ~/ itemCell;
        if (rowW.length - indexY >= length) {
          insertIndex = indexY;
          for (int indexX = 0; indexX < length; indexX++) {
            if (rowW[indexY + indexX] - rowLastW[indexY + indexX] < itemCell) {
            } else if (maxWidth - rowW[indexY + indexX] < size.width) {
              insertIndex = -1;
              break;
            }
          }
          break;
        }
      }
    }
    if (insertIndex == -1) {
      updateRowW(rowW, rowLastW);
    }
    return insertIndex;
  }

  /// 放置item
  void positionItem(List<ItemPosition> itemPositionList) {
    for (ItemPosition element in itemPositionList) {
      /// 放置当前widget
      positionChild(element.id, element.offset);
    }
    // 刷新最大宽度
    double tempWidth = 0.0;
    for (var element in rowW) {
      tempWidth = max(tempWidth, element);
    }
    if (tempWidth != 0.0 && tempWidth > maxContainerWidth) {
      maxContainerWidth = tempWidth;
    }
    rowW.clear();
    rowLastW.clear();
  }

  /// 计算偏移量
  List<ItemPosition> calculateOffset(List<ItemPosition> itemPositionList, List<ItemPosition> dragItemPosition) {
    List<ItemPosition> item = [];
    for (int index = 0; index < itemAll.length; index++) {
      Offset offset = dragItemPosition[index].transform(itemPositionList[index]);
      item.add(ItemPosition(
          itemPositionList[index].id,
          Offset(itemPositionList[index].offset.dx + offset.dx * process,
              itemPositionList[index].offset.dy + offset.dy * process)));
    }
    return item;
  }

  /// 计算每个item位置
  List<ItemPosition> calculateFormLayout(List<ReorderableItem> itemAll) {
    List<ItemPosition> calculateItemPosition = [];

    // Y轴偏移量
    double offsetY = 0;

    // 当前列的index
    int nowColumIndex = 0;
    for (int i = 0; i < itemAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = layoutChild(
          itemAll[i].id!,
          BoxConstraints(
              minWidth: itemCell * (itemAll[i].crossAxisCellCount!) + ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              maxWidth: itemCell * (itemAll[i].crossAxisCellCount!) + ((itemAll[i].crossAxisCellCount!) - 1) * padding,
              minHeight: itemCell * (itemAll[i].mainAxisCellCount!) + ((itemAll[i].mainAxisCellCount!) - 1) * padding,
              maxHeight: itemCell * (itemAll[i].mainAxisCellCount!) + ((itemAll[i].mainAxisCellCount!) - 1) * padding));

      // 当前widget竖排布后越界处理
      if (true) {
        int insertIndex = checkNowColumn(itemSize, itemCell, rowW, rowLastW);
        if (insertIndex == -1) {
          offsetY = 0;
          nowColumIndex = 0;
        } else {
          offsetY = insertIndex * itemCell + (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowColumIndex = insertIndex;
        }
      }

      calculateItemPosition.add(ItemPosition(itemAll[i].id!, Offset(rowW[nowColumIndex], offsetY + padding * 0.5)));

      // 修改y轴偏移量
      offsetY += padding +
          itemCell * (itemAll[i].crossAxisCellCount ?? 1) +
          ((itemAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (int c = 0; c < itemAll[i].mainAxisCellCount!; c++) {
        rowW[nowColumIndex] += itemSize.width + padding;
        if (nowColumIndex < columnNum - 1) {
          nowColumIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }

  @override
  void performLayout(Size size) {
    List<ItemPosition> itemPositionList = calculateFormLayout(itemAll);

    if (itemChangeAll.isEmpty) {
      positionItem(itemPositionList);
    } else {
      List<ItemPosition> dragItemPosition = calculateDragFormLayout(itemChangeAll);
      List<ItemPosition> item = calculateOffset(itemPositionList, dragItemPosition);
      positionItem(item);
    }
  }

  @override
  bool shouldRelayout(covariant ProxyHorizontalClass oldDelegate) {
    if (itemChangeAll.isEmpty || oldDelegate.itemChangeAll.isEmpty) {
      return false;
    }
    for (int index = 0; index < itemAll.length; index++) {
      bool itemEqual = oldDelegate.itemAll[index].compare(itemAll[index]);
      if (!itemEqual) {
        return true;
      }
      bool itemChangeEqual = oldDelegate.itemChangeAll[index].compare(itemChangeAll[index]);
      if (!itemChangeEqual) {
        return true;
      }
      bool itemCompareEqual = oldDelegate.itemAll[index].compare(itemChangeAll[index]);
      if (!itemCompareEqual) {
        return true;
      }
    }
    if (oldDelegate.process != process) {
      return true;
    }
    return false;
  }

  /// 计算拖拽排序后的item位置(拖拽)
  List<ItemPosition> calculateDragFormLayout(List<ReorderableItem> itemChangeAll) {
    List<ItemPosition> calculateItemPosition = [];

    // 累计每列的高度
    List rowW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // 累计上行每列的高度
    List rowLastW = List.generate(columnNum, (index) {
      return 0.0;
    });

    // y轴偏移量
    double offsetY = 0;

    // 当前列的index
    int nowColumIndex = 0;
    for (int i = 0; i < itemChangeAll.length; i++) {
      // 获取当前widget宽高限制
      Size itemSize = getSize(BoxConstraints(
          minWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          maxWidth: itemCell * (itemChangeAll[i].crossAxisCellCount!) +
              ((itemChangeAll[i].crossAxisCellCount!) - 1) * padding,
          minHeight:
              itemCell * (itemChangeAll[i].mainAxisCellCount!) + ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding,
          maxHeight: itemCell * (itemChangeAll[i].mainAxisCellCount!) +
              ((itemChangeAll[i].mainAxisCellCount!) - 1) * padding));

      // 当前widget竖排布后越界处理
      if (true) {
        int insertIndex = checkNowColumn(itemSize, itemCell, rowW, rowLastW);
        if (insertIndex == -1) {
          offsetY = 0;
          nowColumIndex = 0;
        } else {
          offsetY = insertIndex * itemCell + (insertIndex >= 1 ? insertIndex : 0) * padding;
          nowColumIndex = insertIndex;
        }
      }

      calculateItemPosition
          .add(ItemPosition(itemChangeAll[i].id!, Offset(rowW[nowColumIndex], offsetY + padding * 0.5)));

      // 修改y轴偏移量
      offsetY += padding +
          itemCell * (itemChangeAll[i].crossAxisCellCount ?? 1) +
          ((itemChangeAll[i].crossAxisCellCount ?? 1) - 1) * padding;

      // 放置后修改当前行的index指向
      for (int c = 0; c < itemChangeAll[i].mainAxisCellCount!; c++) {
        rowW[nowColumIndex] += itemSize.width + padding;
        if (nowColumIndex < columnNum - 1) {
          nowColumIndex++;
        }
      }
    }
    calculateItemPosition.sort((a, b) => a.id.compareTo(b.id));
    return calculateItemPosition;
  }
}
