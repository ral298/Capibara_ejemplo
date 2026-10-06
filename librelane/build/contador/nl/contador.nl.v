module contador (enable,
    reloj,
    reset,
    suma_resta,
    resultado);
 input enable;
 input reloj;
 input reset;
 input suma_resta;
 output [3:0] resultado;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire _11_;
 wire _12_;
 wire _13_;
 wire _14_;
 wire _15_;
 wire _16_;
 wire _17_;
 wire _18_;
 wire _19_;
 wire _20_;
 wire _21_;
 wire _22_;
 wire _23_;
 wire _24_;
 wire _25_;
 wire _26_;
 wire _27_;
 wire _28_;
 wire net9;
 wire net10;
 wire net11;
 wire net1;
 wire net2;
 wire net3;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net4;
 wire net;

 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_104 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_0_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_0_127 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_0_135 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_0_138 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_0_146 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_0_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_42 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_0_58 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_0_66 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_70 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_0_86 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_10_123 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_10_138 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_10_146 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_10_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_10_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_37 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_53 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_10_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_10_85 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_10_89 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_10_97 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_11_10 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_11_102 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_11_118 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_11_122 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_11_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_11_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_11_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_11_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_11_51 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_11_59 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_11_72 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_11_84 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_11_88 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_11_94 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_12_103 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_12_123 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_12_127 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_12_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_41 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_12_83 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_12_99 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_13_113 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_121 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_13_123 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_137 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_13_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_13_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_13_19 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_13_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_13_35 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_13_51 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_6 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_67 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_13_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_13_72 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_13_8 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_13_88 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_13_97 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_14_101 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_14_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_14_148 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_14_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_14_24 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_14_32 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_14_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_14_37 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_14_45 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_14_61 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_14_77 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_14_93 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_15_109 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_15_125 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_15_129 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_15_131 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_15_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_15_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_15_150 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_15_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_15_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_15_57 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_15_65 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_15_69 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_10 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_16_104 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_16_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_16_138 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_16_149 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_151 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_16_17 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_16_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_33 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_16_36 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_16_52 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_54 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_16_61 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_16_65 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_16_67 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_16_70 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_16_86 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_16_94 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_104 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_1_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_1_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_1_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_50 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_1_66 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_72 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_1_88 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_2_101 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_123 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_2_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_2_147 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_2_151 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_2_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_37 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_53 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_2_85 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_104 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_3_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_3_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_3_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_50 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_3_66 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_72 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_3_88 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_4_101 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_123 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_4_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_4_147 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_4_151 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_4_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_37 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_53 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_4_85 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_104 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_5_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_5_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_5_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_50 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_5_66 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_72 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_5_88 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_107 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_123 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_6_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_6_147 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_6_151 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_18 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_2 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_6_34 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_37 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_57 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_73 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_6_89 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_7_10 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_7_101 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_7_117 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_7_133 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_7_137 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_7_139 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_7_142 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_7_150 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_7_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_7_22 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_7_38 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_7_46 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_7_54 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_7_63 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_7_67 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_7_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_7_72 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_7_88 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_7_93 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_8_10 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_8_100 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_8_104 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_8_117 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_8_12 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_8_125 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_8_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_8_2 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_8_23 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_8_31 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_8_37 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_8_45 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_8_75 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_8_83 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_8_87 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_8_89 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_9_104 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_9_12 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_9_120 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_9_136 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_9_142 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_9_23 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_9_39 ();
 gf180mcu_as_sc_mcu7t3v3__fill_2 FILLER_9_47 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_9_49 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_8 FILLER_9_57 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_9_65 ();
 gf180mcu_as_sc_mcu7t3v3__fill_1 FILLER_9_69 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_9_72 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_4 FILLER_9_8 ();
 gf180mcu_as_sc_mcu7t3v3__fillcap_16 FILLER_9_88 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_0_Left_17 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_0_Right_0 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_10_Left_27 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_10_Right_10 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_11_Left_28 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_11_Right_11 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_12_Left_29 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_12_Right_12 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_13_Left_30 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_13_Right_13 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_14_Left_31 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_14_Right_14 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_15_Left_32 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_15_Right_15 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_16_Left_33 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_16_Right_16 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_1_Left_18 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_1_Right_1 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_2_Left_19 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_2_Right_2 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_3_Left_20 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_3_Right_3 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_4_Left_21 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_4_Right_4 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_5_Left_22 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_5_Right_5 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_6_Left_23 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_6_Right_6 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_7_Left_24 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_7_Right_7 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_8_Left_25 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_8_Right_8 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_9_Left_26 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 PHY_EDGE_ROW_9_Right_9 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_0_34 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_0_35 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_0_36 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_0_37 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_10_56 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_10_57 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_11_58 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_11_59 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_12_60 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_12_61 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_13_62 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_13_63 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_14_64 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_14_65 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_15_66 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_15_67 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_16_68 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_16_69 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_16_70 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_16_71 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_1_38 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_1_39 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_2_40 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_2_41 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_3_42 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_3_43 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_4_44 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_4_45 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_5_46 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_5_47 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_6_48 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_6_49 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_7_50 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_7_51 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_8_52 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_8_53 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_9_54 ();
 gf180mcu_as_sc_mcu7t3v3__tap_2 TAP_TAPCELL_ROW_9_55 ();
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _33_ (.Y(_04_),
    .B(net7),
    .A(net4));
 gf180mcu_as_sc_mcu7t3v3__inv_2 _34_ (.Y(_05_),
    .A(net4));
 gf180mcu_as_sc_mcu7t3v3__nand2b_2 _35_ (.Y(_06_),
    .B(_05_),
    .A(net7));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _36_ (.Y(_07_),
    .B(_06_),
    .A(_04_));
 gf180mcu_as_sc_mcu7t3v3__inv_6 _37_ (.Y(_08_),
    .A(net5));
 gf180mcu_as_sc_mcu7t3v3__inv_4 _38_ (.Y(_09_),
    .A(net6));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _39_ (.Y(_10_),
    .B(_09_),
    .A(net4));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _40_ (.Y(_11_),
    .B(_05_),
    .A(net6));
 gf180mcu_as_sc_mcu7t3v3__inv_2 _41_ (.Y(_12_),
    .A(_11_));
 gf180mcu_as_sc_mcu7t3v3__aoi21b_4 _42_ (.Y(_13_),
    .C(_12_),
    .A(_08_),
    .B(_10_));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _43_ (.Y(_14_),
    .B(_13_),
    .A(_07_));
 gf180mcu_as_sc_mcu7t3v3__inv_2 _44_ (.Y(_15_),
    .A(_13_));
 gf180mcu_as_sc_mcu7t3v3__nand2b_2 _45_ (.Y(_16_),
    .B(_15_),
    .A(_07_));
 gf180mcu_as_sc_mcu7t3v3__nor2_2 _46_ (.Y(_17_),
    .B(net1),
    .A(net7));
 gf180mcu_as_sc_mcu7t3v3__aoi31_4 _47_ (.A(net1),
    .B(_14_),
    .C(_16_),
    .D(_17_),
    .Y(_00_));
 gf180mcu_as_sc_mcu7t3v3__inv_2 _48_ (.Y(_18_),
    .A(net8));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _49_ (.Y(_19_),
    .B(_13_),
    .A(_06_));
 gf180mcu_as_sc_mcu7t3v3__nor2b_2 _50_ (.Y(_20_),
    .B(_13_),
    .A(_04_));
 gf180mcu_as_sc_mcu7t3v3__nor2b_2 _51_ (.Y(_21_),
    .B(_20_),
    .A(net1));
 gf180mcu_as_sc_mcu7t3v3__nand3_2 _52_ (.A(_18_),
    .B(_19_),
    .C(_21_),
    .Y(_22_));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _53_ (.Y(_23_),
    .B(_15_),
    .A(_04_));
 gf180mcu_as_sc_mcu7t3v3__nand3_2 _54_ (.A(net1),
    .B(_19_),
    .C(_23_),
    .Y(_24_));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _55_ (.Y(_25_),
    .B(_24_),
    .A(net8));
 gf180mcu_as_sc_mcu7t3v3__nand2_4 _56_ (.Y(_01_),
    .A(_22_),
    .B(_25_));
 gf180mcu_as_sc_mcu7t3v3__xor2_2 _57_ (.B(net1),
    .A(net5),
    .Y(_02_));
 gf180mcu_as_sc_mcu7t3v3__nand2_2 _58_ (.Y(_26_),
    .B(_10_),
    .A(_11_));
 gf180mcu_as_sc_mcu7t3v3__oai21_2 _59_ (.A(_08_),
    .B(_26_),
    .C(net1),
    .Y(_27_));
 gf180mcu_as_sc_mcu7t3v3__ao21_2 _60_ (.Y(_28_),
    .A(_08_),
    .B(_26_),
    .C(_27_));
 gf180mcu_as_sc_mcu7t3v3__oai21_2 _61_ (.A(_09_),
    .B(net1),
    .C(_28_),
    .Y(_03_));
 gf180mcu_as_sc_mcu7t3v3__dfsrtp_2 _62_ (.CLK(net2),
    .Q(net5),
    .RN(net3),
    .SN(net9),
    .D(_02_));
 gf180mcu_as_sc_mcu7t3v3__tieh_4 _62__10 (.ONE(net9));
 gf180mcu_as_sc_mcu7t3v3__dfsrtp_2 _63_ (.CLK(net2),
    .Q(net6),
    .RN(net3),
    .SN(net),
    .D(_03_));
 gf180mcu_as_sc_mcu7t3v3__tieh_4 _63__9 (.ONE(net));
 gf180mcu_as_sc_mcu7t3v3__dfsrtp_2 _64_ (.CLK(net2),
    .Q(net7),
    .RN(net3),
    .SN(net11),
    .D(_00_));
 gf180mcu_as_sc_mcu7t3v3__tieh_4 _64__12 (.ONE(net11));
 gf180mcu_as_sc_mcu7t3v3__dfsrtp_2 _65_ (.CLK(net2),
    .Q(net8),
    .RN(net3),
    .SN(net10),
    .D(_01_));
 gf180mcu_as_sc_mcu7t3v3__tieh_4 _65__11 (.ONE(net10));
 gf180mcu_as_sc_mcu7t3v3__buff_2 input1 (.A(enable),
    .Y(net1));
 gf180mcu_as_sc_mcu7t3v3__buff_2 input2 (.A(reloj),
    .Y(net2));
 gf180mcu_as_sc_mcu7t3v3__buff_2 input3 (.A(reset),
    .Y(net3));
 gf180mcu_as_sc_mcu7t3v3__buff_2 input4 (.A(suma_resta),
    .Y(net4));
 gf180mcu_as_sc_mcu7t3v3__buff_2 output5 (.A(net5),
    .Y(resultado[0]));
 gf180mcu_as_sc_mcu7t3v3__buff_2 output6 (.A(net6),
    .Y(resultado[1]));
 gf180mcu_as_sc_mcu7t3v3__buff_2 output7 (.A(net7),
    .Y(resultado[2]));
 gf180mcu_as_sc_mcu7t3v3__buff_2 output8 (.A(net8),
    .Y(resultado[3]));
endmodule
