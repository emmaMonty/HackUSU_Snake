vga_pll_inst : vga_pll PORT MAP (
		areset	 => areset_sig,
		inclk0	 => inclk0_sig,
		c0	 => c0_sig,
		c2	 => c2_sig,
		c3	 => c3_sig,
		c4	 => c4_sig,
		locked	 => locked_sig
	);
