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
  final double padding;

  /// 是否允许拖拽
  final bool canDrag;

  const StaggeredReorderableView.customer({
    Key? key,
    required List<CustomerItem> children,
    Axis scrollDirection = Axis.vertical,
    Duration duration = const Duration(milliseconds: 300),
    Duration? antiShakeDuration,
    bool collation = false,
    int columnNum = 3,
    double padding = 5.0,
    bool canDrag = true,
  }) : this(
          key: key,
          children: children,
          scrollDirection: scrollDirection,
          duration: duration,
          antiShakeDuration: const Duration(milliseconds: 100),
          collation: collation,
          columnNum: columnNum,
          padding: padding,
          canDrag: canDrag,
        );

  const StaggeredReorderableView({
    Key? key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.duration = const Duration(milliseconds: 300),
    this.antiShakeDuration = const Duration(milliseconds: 100),
    this.collation = false,
    this.columnNum = 3,
    this.padding = 5.0,
    this.canDrag = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomerMultiChildView(
        children, columnNum, padding, duration, antiShakeDuration, canDrag,
        collation: collation, scrollDirection: scrollDirection);
  }
}
