/* Quartus Prime Version 19.3.0 Build 222 09/23/2019 SC Pro Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(1SM21BHU2F53S1) Path("./") File("alt_ehipc2_hw.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(VTAP10) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
