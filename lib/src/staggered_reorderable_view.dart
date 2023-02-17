import 'package:flutter/material.dart';
import 'cutomer_multi_child_layout_view.dart';

import 'item_model.dart';

/// guoshijun created this file at 2022/5/7 4:22 下午
///
/// 可拖拽的不规则图形瀑布流

class StaggeredReorderableView extends StatelessWidget {
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
  /// [CustomerItem.id]不允许存在重复值
  /// [CustomerItem.index]不允许存在重复值
  final List<CustomerItem> children;

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
  const StaggeredReorderableView({
    Key? key,
    required this.children,
    this.columnNum = 3,
    // TODO: Fix spacing error that doesn't center objects. The problem is that it leaves the spacing in the last position of a row, making all widgets align "start" in the row
    this.spacing = 5.0,
    this.canDrag = true,
    this.collation = false,
    this.containerHeight = 600.0,
    this.backgroundColor = Colors.grey,
    this.onDragBackgroundColor = Colors.white,
    this.scrollDirection = Axis.vertical,
    this.duration = const Duration(milliseconds: 300),
    this.antiShakeDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomerMultiChildView(
      itemAll: children,
      columnNum: columnNum,
      spacing: spacing,
      duration: duration,
      antiShakeDuration: antiShakeDuration,
      canDrag: canDrag,
      collation: collation,
      scrollDirection: scrollDirection,
      containerHeight: containerHeight,
      backgroundColor: backgroundColor,
      onDragBackgroundColor: onDragBackgroundColor,
    );
  }
}
