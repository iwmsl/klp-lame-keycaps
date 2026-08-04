# KLP Lamé Angular (OpenSCAD)

![](../Assets/KLP-Lame-Angular-Preview.png)

KLP Lamé の特徴である「中央がくぼみ四辺が持ち上がる皿状の天面(前後のロールオフ)」を
保ちつつ、側面を**フラットで角のはっきりした台形**にした **角ばった・低背リミックス** です。
天面は元と同じ球面ディッシュ、側面はフラット、稜線だけを軽く丸めた「ラウンデッドボックス」構成。
OpenSCAD 製のフルパラメトリックモデルなので、寸法・形状を自由に調整できます。

An angular, lower-profile remix of KLP Lamé. Flat, crisp trapezoid
sides (a "rounded box" with only the perimeter edges softened) carry
the same spherical dish as the original — concave scoop rising toward
all four edges, rolling off over the front/back walls. Fully parametric
OpenSCAD source. Stem and cavity dimensions are measured from the
original STLs, so switch fit is identical to the originals.

## 特徴 / Features

- **角ばった形状** — 側面はフラット、稜線のみ軽い丸め。19mmピッチ向けに底面18×18mm
- **皿状の天面は維持** — 元と同じ球面ディッシュ(中央がくぼみ四辺へ持ち上がる)。
  Tilted は 10° 傾斜。前端をホーム段と同じ高さにして段差なくつなげています
- **低背化** — クラウン高さ 5.0 mm(オリジナル約 5.6 mm より低い)、
  指の当たる谷底は約 3.9 mm
- **互換ステム** — Choc(2本足 1.15×2.95、間隔5.7)/ MX(Ø5.5 ボス+十字)
  はオリジナル実測値そのまま
- **FDM向け** — Bambu Lab A1 mini でのプリントを想定(内側ボトムチャンファ付き)

## バリアント / Variants

4 種 × ステム(Choc/MX) × サイズ(Choc 17.5×16.5 / MX 18×18):

| Variant | 説明 |
| :--- | :--- |
| Normal | 皿状のくぼみを持つ基本形 |
| Normal Homing | Normal+ホーミングバー |
| Normal Tilted | 10° 傾斜(上下段用) |
| 1.5U Normal | Normal の 1.5U 幅版(親指用) |

ビルド済み STL は `STL/` 以下(`build.sh` で再生成できます)。
ホーミングは `homing = "dots"` でオリジナル風の3点バンプにも変更可能です。

## 側面スタイル / Sidewall styles

19mm ピッチでキー間の隙間をどれだけ詰めるかを `side_style` で選べます。

| スタイル | 側面 | 天面 | 天面どうしの隙間 |
| :--- | :--- | :--- | :--- |
| **chiclet**(既定) | ほぼ垂直(約13°) | 16.5×16.5 | 2.5 mm |
| wide | 従来のテーパー(約29°) | 14×14 | 5.0 mm |
| skirt | 下1.5mmは垂直、その上テーパー | 15×15 | リム1.0 / 上4.0 mm |

![](../Assets/KLP-Lame-Angular-SideStyles-Profile.png)

## Corne v4 Mini 印刷セット / Print set

[c4mtb](https://github.com/iwmsl/c4mtb)(Corne v4 Mini 相当)向けの
**両手36キー一式**を、Bambu Lab A1 mini(180×180mm)にそのまま並べた
プレートを用意しています(`MX Stem + MX Size`)。詳細は
[Plates/README.md](./Plates/README.md)。

| ファイル | 向き | 特徴 |
| :--- | :--- | :--- |
| **`Plates/Plate_A1mini_Corne36_Tipped.stl`**(推奨) | **上向きから50°傾ける** | **36キー一括・サポート不要。外側の最大オーバーハングは50°、45°超はわずか0.2mm²。天面の積層痕も出ません。151×112mm** |
| `Plates/Plate_A1mini_Corne36_BottomDown.stl` | 上向き(底面を下) | 最も安定しオーバーハングも下3mmだけ。ただし天面に同心円状の積層痕が出ます。150×165mm |
| `Plates/Plate_A1mini_Test_OneEach_RearSideDown.stl` | Normal / Normal Tilted は後側面を下、ほかは自動選択面 | 全4種を各1個。8mmブリム推奨 |

試作版の内訳: Normal / Normal Homing / Normal Tilted / 1.5U Normal を各1個。

36キー版の内訳: Normal Tilted×20 / Normal×12(ホーム段8＋1U親指4) /
Normal Homing×2 / 1.5U Normal×2 = 36。

![](../Assets/KLP-Lame-Angular-Plate-Corne36.png)

## 使い方 / Usage

### OpenSCAD GUI(カスタマイザ)

`klp-lame-angular.scad` を開いて Customizer からパラメータを変更し、
F6 → STL エクスポート。主なパラメータ:

| パラメータ | 既定値 | 説明 |
| :--- | :--- | :--- |
| `stem_type` | choc | choc / mx |
| `size_type` | mx | choc (17.5×16.5) / mx (18×18、19mmピッチ向け) |
| `variant` | normal | normal / tilted |
| `homing` | none | none / bar / dots |
| `crown_height` | 5.0 | クラウン(天面の外周稜線)の高さ ※ |
| `dish_depth` | 1.15 | 中央のくぼみ深さ。谷底 = `crown_height` − `dish_depth` |
| `dish_radius` | 28 | 球面ディッシュのR(小さいほど深く丸い皿) |
| `side_style` | chiclet | chiclet / wide / skirt(上表参照) |
| `top_edge_round` | 1.0 | 上端稜線の丸め |
| `corner_radius` | 1.9 | 底面の角R(小さいほど角ばる) |
| `rear_inset` | -1 | 後面上端のインセット。負値で側面と同じ＝前後対称(既定)。0にすると後面が垂直になりますが、印刷上の効果はごく僅かです |
| `tilt_angle` / `tilt_front_height` | 10 / 5.0 | Tilted の傾斜角と前端高さ。前端＝`crown_height` でホーム段と段差なし |

※ 谷底(`crown_height` − `dish_depth`)− 空洞深さ(約2.0)が天板の最小厚です。
既定値で約 1.85 mm。FDM なら 1.0 mm 以上を推奨します。

### CLI

```sh
# 単品
openscad -o cap.stl -D 'stem_type="mx"' -D 'size_type="mx"' -D 'variant="tilted"' klp-lame-angular.scad

# 全16種 + プレート + プレビュー画像
./build.sh
```

## Bambu Lab A1 mini での印刷 / Printing

**上向きから45°傾けて、サポートなしで印刷するのを推奨します。**

判断の決め手は「外側の見える面のうち45°を超える面積」です。キャビティとステムは
装着後は見えず、天井も両端が支持されたブリッジなので同列に扱う必要がありません。

| 傾き | 外側の最大角 | 45°超の面積 |
| --: | --: | --: |
| 45° | 54° | 35.0 mm² |
| **50°** | **50°** | **0.2 mm²** |
| 90°(寝かせ) | 90° | 80.8 mm² |

1Uでは外側に50°を超える面が存在しません(1.5Uのみ56°/8.5mm²)。
これは `bottom_edge_round = 0` が前提です。この45°面取りは底面を下で印刷する際の
エレファントフット対策でしたが、45°前後に傾けると**完全水平の8.8mm²の棚**に変わり、
モデル全体で最悪のオーバーハングになっていました。

なお内部(キャビティ・ステム)には45°超が62mm²残ります。すべて隠れる面で、
天井は両端支持のブリッジですが、ステムのはめ合いがきつくなる可能性はあります。

- ノズル: 0.4 mm / レイヤー: 0.08–0.12 mm
- 壁: 4 以上、インフィル: 100%(小さい部品なのでほぼ変わりません)
- 向き: 50°傾け(推奨)。**サポート不要**。ブリムは3mm程度
- 試作プレート: 接地面が小さいため8mmブリム推奨
- 材料: PLA / PETG(テクスチャPEIプレート)
- シーム: 後方に寄せる(Seam position: Rear)
- はめ合いがきつい/ゆるい場合: Bambu Studio の
  「X-Y hole compensation」を ±0.05 mm 程度調整するか、
  scad の `choc_leg_w` / `mx_slot_v` などを直接調整

レジン印刷でも問題ありません(その場合 `foot_chamfer` は 0 でも可)。

## クレジット / Credit

Original KLP Lamé by [braindefender](https://github.com/braindefender/KLP-Lame-Keycaps).
This remix follows the same license — keep the credit to the original author.
