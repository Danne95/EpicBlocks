import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shape.dart';
import 'package:flutter/material.dart';

/// Catalog of available EpicBlocks shapes.
class BlockShapes {
  const BlockShapes._();

  static const _singleLight = Color(0xFF2563EB);
  static const _singleDark = Color(0xFF60A5FA);
  static const _bar2Light = Color(0xFF059669);
  static const _bar2Dark = Color(0xFF34D399);
  static const _bar3Light = Color(0xFFDC2626);
  static const _bar3Dark = Color(0xFFF87171);
  static const _bar4Light = Color(0xFF9333EA);
  static const _bar4Dark = Color(0xFFC084FC);
  static const _bar5Light = Color(0xFFEA580C);
  static const _bar5Dark = Color(0xFFFB923C);
  static const _square2Light = Color(0xFF0891B2);
  static const _square2Dark = Color(0xFF67E8F9);
  static const _square3Light = Color(0xFF0D9488);
  static const _square3Dark = Color(0xFF5EEAD4);
  static const _cornerLight = Color(0xFFE11D48);
  static const _cornerDark = Color(0xFFFB7185);
  static const _largeLLight = Color(0xFF4F46E5);
  static const _largeLDark = Color(0xFFA5B4FC);
  static const _tLight = Color(0xFFA16207);
  static const _tDark = Color(0xFFFACC15);
  static const _sLight = Color(0xFF15803D);
  static const _sDark = Color(0xFF86EFAC);
  static const _zLight = Color(0xFF0F766E);
  static const _zDark = Color(0xFF99F6E4);

  /// Full 1010-like shape catalog.
  static const all = <BlockShape>[
    BlockShape(
      id: 'single',
      label: 'Single block',
      cells: [BlockPosition(0, 0)],
      lightColor: _singleLight,
      darkColor: _singleDark,
    ),
    BlockShape(
      id: 'bar_2_h',
      label: 'Two horizontal',
      cells: [BlockPosition(0, 0), BlockPosition(0, 1)],
      lightColor: _bar2Light,
      darkColor: _bar2Dark,
    ),
    BlockShape(
      id: 'bar_2_v',
      label: 'Two vertical',
      cells: [BlockPosition(0, 0), BlockPosition(1, 0)],
      lightColor: _bar2Light,
      darkColor: _bar2Dark,
    ),
    BlockShape(
      id: 'bar_3_h',
      label: 'Three horizontal',
      cells: [BlockPosition(0, 0), BlockPosition(0, 1), BlockPosition(0, 2)],
      lightColor: _bar3Light,
      darkColor: _bar3Dark,
    ),
    BlockShape(
      id: 'bar_3_v',
      label: 'Three vertical',
      cells: [BlockPosition(0, 0), BlockPosition(1, 0), BlockPosition(2, 0)],
      lightColor: _bar3Light,
      darkColor: _bar3Dark,
    ),
    BlockShape(
      id: 'bar_4_h',
      label: 'Four horizontal',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(0, 3),
      ],
      lightColor: _bar4Light,
      darkColor: _bar4Dark,
    ),
    BlockShape(
      id: 'bar_4_v',
      label: 'Four vertical',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(1, 0),
        BlockPosition(2, 0),
        BlockPosition(3, 0),
      ],
      lightColor: _bar4Light,
      darkColor: _bar4Dark,
    ),
    BlockShape(
      id: 'bar_5_h',
      label: 'Five horizontal',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(0, 3),
        BlockPosition(0, 4),
      ],
      lightColor: _bar5Light,
      darkColor: _bar5Dark,
    ),
    BlockShape(
      id: 'bar_5_v',
      label: 'Five vertical',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(1, 0),
        BlockPosition(2, 0),
        BlockPosition(3, 0),
        BlockPosition(4, 0),
      ],
      lightColor: _bar5Light,
      darkColor: _bar5Dark,
    ),
    BlockShape(
      id: 'square_2',
      label: 'Two by two square',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
      ],
      lightColor: _square2Light,
      darkColor: _square2Dark,
    ),
    BlockShape(
      id: 'square_3',
      label: 'Three by three square',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(1, 2),
        BlockPosition(2, 0),
        BlockPosition(2, 1),
        BlockPosition(2, 2),
      ],
      lightColor: _square3Light,
      darkColor: _square3Dark,
    ),
    BlockShape(
      id: 'corner_tl',
      label: 'Corner top left',
      cells: [BlockPosition(0, 0), BlockPosition(1, 0), BlockPosition(1, 1)],
      lightColor: _cornerLight,
      darkColor: _cornerDark,
    ),
    BlockShape(
      id: 'corner_tr',
      label: 'Corner top right',
      cells: [BlockPosition(0, 1), BlockPosition(1, 0), BlockPosition(1, 1)],
      lightColor: _cornerLight,
      darkColor: _cornerDark,
    ),
    BlockShape(
      id: 'corner_bl',
      label: 'Corner bottom left',
      cells: [BlockPosition(0, 0), BlockPosition(0, 1), BlockPosition(1, 0)],
      lightColor: _cornerLight,
      darkColor: _cornerDark,
    ),
    BlockShape(
      id: 'corner_br',
      label: 'Corner bottom right',
      cells: [BlockPosition(0, 0), BlockPosition(0, 1), BlockPosition(1, 1)],
      lightColor: _cornerLight,
      darkColor: _cornerDark,
    ),
    BlockShape(
      id: 'l_4_down_right',
      label: 'Large L down right',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(1, 0),
        BlockPosition(2, 0),
        BlockPosition(2, 1),
      ],
      lightColor: _largeLLight,
      darkColor: _largeLDark,
    ),
    BlockShape(
      id: 'l_4_down_left',
      label: 'Large L down left',
      cells: [
        BlockPosition(0, 1),
        BlockPosition(1, 1),
        BlockPosition(2, 0),
        BlockPosition(2, 1),
      ],
      lightColor: _largeLLight,
      darkColor: _largeLDark,
    ),
    BlockShape(
      id: 'l_4_right_down',
      label: 'Large L right down',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(1, 0),
      ],
      lightColor: _largeLLight,
      darkColor: _largeLDark,
    ),
    BlockShape(
      id: 'l_4_right_up',
      label: 'Large L right up',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(1, 2),
      ],
      lightColor: _largeLLight,
      darkColor: _largeLDark,
    ),
    BlockShape(
      id: 't_up',
      label: 'T up',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(1, 1),
      ],
      lightColor: _tLight,
      darkColor: _tDark,
    ),
    BlockShape(
      id: 't_down',
      label: 'T down',
      cells: [
        BlockPosition(0, 1),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(1, 2),
      ],
      lightColor: _tLight,
      darkColor: _tDark,
    ),
    BlockShape(
      id: 't_left',
      label: 'T left',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(2, 0),
      ],
      lightColor: _tLight,
      darkColor: _tDark,
    ),
    BlockShape(
      id: 't_right',
      label: 'T right',
      cells: [
        BlockPosition(0, 1),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(2, 1),
      ],
      lightColor: _tLight,
      darkColor: _tDark,
    ),
    BlockShape(
      id: 's_h',
      label: 'S horizontal',
      cells: [
        BlockPosition(0, 1),
        BlockPosition(0, 2),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
      ],
      lightColor: _sLight,
      darkColor: _sDark,
    ),
    BlockShape(
      id: 's_v',
      label: 'S vertical',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(2, 1),
      ],
      lightColor: _sLight,
      darkColor: _sDark,
    ),
    BlockShape(
      id: 'z_h',
      label: 'Z horizontal',
      cells: [
        BlockPosition(0, 0),
        BlockPosition(0, 1),
        BlockPosition(1, 1),
        BlockPosition(1, 2),
      ],
      lightColor: _zLight,
      darkColor: _zDark,
    ),
    BlockShape(
      id: 'z_v',
      label: 'Z vertical',
      cells: [
        BlockPosition(0, 1),
        BlockPosition(1, 0),
        BlockPosition(1, 1),
        BlockPosition(2, 0),
      ],
      lightColor: _zLight,
      darkColor: _zDark,
    ),
  ];
}
