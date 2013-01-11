require 'formula'

class Vim < Formula
  homepage 'http://www.vim.org/'
  # Get stable versions from hg repo instead of downloading an increasing
  # number of separate patches.
  url 'https://vim.googlecode.com/hg/', :revision => 'b89e2bdcc6e5'
  version '7.3.762'

  head 'https://vim.googlecode.com/hg/'

  def patches
	  # Add breakindent command
	  #"https://retracile.net/raw-attachment/blog/2011/08/23/21.30/vim-7.3.285-breakindent.patch"
	  DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--enable-gui=no",
                          "--without-x",
                          "--disable-nls",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--enable-pythoninterp",
                          "--enable-rubyinterp",
                          "--enable-cscope",
                          "--with-ruby-command=/usr/bin/ruby",
                          "--with-features=huge"
    system "make"
    system "make install"

    ln_s bin+"vim", "vi"
    bin.install "vi"
  end
end


__END__
diff -r b89e2bdcc6e5 runtime/doc/eval.txt
--- a/runtime/doc/eval.txt	Sun Dec 16 12:50:40 2012 +0100
+++ b/runtime/doc/eval.txt	Fri Jan 11 11:13:16 2013 -0600
@@ -6357,8 +6357,8 @@
 keymap			Compiled with 'keymap' support.
 langmap			Compiled with 'langmap' support.
 libcall			Compiled with |libcall()| support.
-linebreak		Compiled with 'linebreak', 'breakat' and 'showbreak'
-			support.
+linebreak		Compiled with 'linebreak', 'breakat', 'showbreak' and
+			'breakindent' support.
 lispindent		Compiled with support for lisp indenting.
 listcmds		Compiled with commands for the buffer list |:files|
 			and the argument list |arglist|.
diff -r b89e2bdcc6e5 runtime/doc/options.txt
--- a/runtime/doc/options.txt	Sun Dec 16 12:50:40 2012 +0100
+++ b/runtime/doc/options.txt	Fri Jan 11 11:13:16 2013 -0600
@@ -1191,6 +1191,39 @@
 	break if 'linebreak' is on.  Only works for ASCII and also for 8-bit
 	characters when 'encoding' is an 8-bit encoding.
 
+	
+						*'breakindent'* *'bri'*
+'breakindent' 'bri'	boolean (default off)
+			local to window
+			{not in Vi}
+			{not available when compiled without the |+linebreak|
+			feature}
+	Every wrapped line will continue visually indented (same amount of
+	space as the beginning of that line), thus preserving horizontal blocks
+	of text.
+
+						*'breakindentmin'* *'brimin'*
+'breakindentmin' 'brimin' number (default 20)
+			local to window
+			{not in Vi}
+			{not available when compiled without the |+linebreak|
+			feature}
+	Minimum text width that will be kept after applying 'breakindent',
+	even if the resulting text should normally be narrower. This prevents
+	text indented almost to the right window border oocupying lot of
+	vertical space when broken.
+
+						*'breakindentshift'* *'brishift'*
+'breakindentshift' 'brishift' number (default 20)
+			local to window
+			{not in Vi}
+			{not available when compiled without the |+linebreak|
+			feature}
+	After applying 'breakindent', wrapped line beginning will be shift by
+	given number of characters. It permits dynamic French paragraph
+	indentation (negative) or emphasizing the line continuation
+	(positive).
+
 						*'browsedir'* *'bsdir'*
 'browsedir' 'bsdir'	string	(default: "last")
 			global
@@ -4509,12 +4542,13 @@
 			{not in Vi}
 			{not available when compiled without the |+linebreak|
 			feature}
-	If on Vim will wrap long lines at a character in 'breakat' rather
+	If on, Vim will wrap long lines at a character in 'breakat' rather
 	than at the last character that fits on the screen.  Unlike
 	'wrapmargin' and 'textwidth', this does not insert <EOL>s in the file,
-	it only affects the way the file is displayed, not its contents.  The
-	value of 'showbreak' is used to put in front of wrapped lines.
-	This option is not used when the 'wrap' option is off or 'list' is on.
+	it only affects the way the file is displayed, not its contents.
+	If 'breakindent' is set, line is visually indented. Then, the value
+	of 'showbreak' is used to put in front of wrapped lines. This option
+	is not used when the 'wrap' option is off or 'list' is on.
 	Note that <Tab> characters after an <EOL> are mostly not displayed
 	with the right amount of white space.
 
diff -r b89e2bdcc6e5 runtime/doc/tags
--- a/runtime/doc/tags	Sun Dec 16 12:50:40 2012 +0100
+++ b/runtime/doc/tags	Fri Jan 11 11:13:16 2013 -0600
@@ -90,6 +90,12 @@
 'bl'	options.txt	/*'bl'*
 'bomb'	options.txt	/*'bomb'*
 'breakat'	options.txt	/*'breakat'*
+'breakindent'	options.txt	/*'breakindent'*
+'breakindentmin'	options.txt	/*'breakindentmin'*
+'breakindentshift'	options.txt	/*'breakindentshift'*
+'bri'	options.txt	/*'bri'*
+'brimin'	options.txt	/*'brimin'*
+'brishift'	options.txt	/*'brishift'*
 'brk'	options.txt	/*'brk'*
 'browsedir'	options.txt	/*'browsedir'*
 'bs'	options.txt	/*'bs'*
diff -r b89e2bdcc6e5 runtime/optwin.vim
--- a/runtime/optwin.vim	Sun Dec 16 12:50:40 2012 +0100
+++ b/runtime/optwin.vim	Fri Jan 11 11:13:16 2013 -0600
@@ -322,6 +322,15 @@
 call append("$", "linebreak\twrap long lines at a character in 'breakat'")
 call append("$", "\t(local to window)")
 call <SID>BinOptionL("lbr")
+call append("$", "breakindent\tpreserve indentation in wrapped text")
+call append("$", "\t(local to window)")
+call <SID>BinOptionL("bri")
+call append("$", "breakindentmin\tminimum text width after indent in 'breakindent'")
+call append("$", "\t(local to window)")
+call <SID>OptionL("brimin")
+call append("$", "breakindentshift\tshift beginning of 'breakindent'ed line by this number of characters (negative left)")
+call append("$", "\t(local to window)")
+call <SID>OptionL("brishift")
 call append("$", "breakat\twhich characters might cause a line break")
 call <SID>OptionG("brk", &brk)
 call append("$", "showbreak\tstring to put before wrapped screen lines")
diff -r b89e2bdcc6e5 src/charset.c
--- a/src/charset.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/charset.c	Fri Jan 11 11:13:16 2013 -0600
@@ -847,24 +847,26 @@
  * taking into account the size of a tab.
  */
     int
-linetabsize(s)
+linetabsize(s, lnum)
     char_u	*s;
+    linenr_T	lnum;
 {
-    return linetabsize_col(0, s);
+    return linetabsize_col(0, s, lnum);
 }
 
 /*
  * Like linetabsize(), but starting at column "startcol".
  */
     int
-linetabsize_col(startcol, s)
+linetabsize_col(startcol, s, lnum)
     int		startcol;
     char_u	*s;
+    linenr_T	lnum;
 {
     colnr_T	col = startcol;
 
     while (*s != NUL)
-	col += lbr_chartabsize_adv(&s, col);
+	col += lbr_chartabsize_adv(&s, col, lnum);
     return (int)col;
 }
 
@@ -872,16 +874,17 @@
  * Like linetabsize(), but for a given window instead of the current one.
  */
     int
-win_linetabsize(wp, p, len)
+win_linetabsize(wp, p, len, lnum)
     win_T	*wp;
     char_u	*p;
     colnr_T	len;
+    linenr_T	lnum;
 {
     colnr_T	col = 0;
     char_u	*s;
 
     for (s = p; *s != NUL && (len == MAXCOL || s < p + len); mb_ptr_adv(s))
-	col += win_lbr_chartabsize(wp, s, col, NULL);
+	col += win_lbr_chartabsize(wp, s, col, NULL, lnum);
     return (int)col;
 }
 
@@ -1010,12 +1013,13 @@
  * like chartabsize(), but also check for line breaks on the screen
  */
     int
-lbr_chartabsize(s, col)
+lbr_chartabsize(s, col, lnum)
     unsigned char	*s;
     colnr_T		col;
+    linenr_T		lnum;
 {
 #ifdef FEAT_LINEBREAK
-    if (!curwin->w_p_lbr && *p_sbr == NUL)
+    if (!curwin->w_p_lbr && *p_sbr == NUL && !curwin->w_p_bri)
     {
 #endif
 #ifdef FEAT_MBYTE
@@ -1025,7 +1029,7 @@
 	RET_WIN_BUF_CHARTABSIZE(curwin, curbuf, s, col)
 #ifdef FEAT_LINEBREAK
     }
-    return win_lbr_chartabsize(curwin, s, col, NULL);
+    return win_lbr_chartabsize(curwin, s, col, NULL, lnum);
 #endif
 }
 
@@ -1033,13 +1037,14 @@
  * Call lbr_chartabsize() and advance the pointer.
  */
     int
-lbr_chartabsize_adv(s, col)
+lbr_chartabsize_adv(s, col, lnum)
     char_u	**s;
     colnr_T	col;
+    linenr_T	lnum;
 {
     int		retval;
 
-    retval = lbr_chartabsize(*s, col);
+    retval = lbr_chartabsize(*s, col, lnum);
     mb_ptr_adv(*s);
     return retval;
 }
@@ -1050,13 +1055,17 @@
  * If "headp" not NULL, set *headp to the size of what we for 'showbreak'
  * string at start of line.  Warning: *headp is only set if it's a non-zero
  * value, init to 0 before calling.
+ *
+ * linenr argument needed if in visual highlighting and breakindent=on, then
+ * the line calculated is not current; if 0, normal functionality is preserved.
  */
     int
-win_lbr_chartabsize(wp, s, col, headp)
+win_lbr_chartabsize(wp, s, col, headp, lnum)
     win_T	*wp;
     char_u	*s;
     colnr_T	col;
     int		*headp UNUSED;
+    linenr_T	lnum;
 {
 #ifdef FEAT_LINEBREAK
     int		c;
@@ -1075,9 +1084,9 @@
     int		n;
 
     /*
-     * No 'linebreak' and 'showbreak': return quickly.
+     * No 'linebreak' and 'showbreak' and 'breakindent': return quickly.
      */
-    if (!wp->w_p_lbr && *p_sbr == NUL)
+    if (!wp->w_p_lbr && !wp->w_p_bri && *p_sbr == NUL)
 #endif
     {
 #ifdef FEAT_MBYTE
@@ -1152,11 +1161,12 @@
 # endif
 
     /*
-     * May have to add something for 'showbreak' string at start of line
+     * May have to add something for 'breakindent' and/or 'showbreak'
+     * string at start of line.
      * Set *headp to the size of what we add.
      */
     added = 0;
-    if (*p_sbr != NUL && wp->w_p_wrap && col != 0)
+    if ((*p_sbr != NUL || wp->w_p_bri) && wp->w_p_wrap && col != 0)
     {
 	numberextra = win_col_off(wp);
 	col += numberextra + mb_added;
@@ -1169,7 +1179,12 @@
 	}
 	if (col == 0 || col + size > (colnr_T)W_WIDTH(wp))
 	{
-	    added = vim_strsize(p_sbr);
+	    added = 0;
+	    if (*p_sbr != NUL)
+		added += vim_strsize(p_sbr);
+	    if (wp->w_p_bri)
+		added += get_breakindent_win(wp,lnum);
+
 	    if (tab_corr)
 		size += (added / wp->w_buffer->b_p_ts) * wp->w_buffer->b_p_ts;
 	    else
@@ -1277,12 +1292,13 @@
 
     /*
      * This function is used very often, do some speed optimizations.
-     * When 'list', 'linebreak' and 'showbreak' are not set use a simple loop.
+     * When 'list', 'linebreak', 'showbreak' and 'breakindent' are not set
+     * use a simple loop.
      * Also use this when 'list' is set but tabs take their normal size.
      */
     if ((!wp->w_p_list || lcs_tab1 != NUL)
 #ifdef FEAT_LINEBREAK
-	    && !wp->w_p_lbr && *p_sbr == NUL
+	    && !wp->w_p_lbr && *p_sbr == NUL && !wp->w_p_bri
 #endif
        )
     {
@@ -1344,7 +1360,7 @@
 	{
 	    /* A tab gets expanded, depending on the current column */
 	    head = 0;
-	    incr = win_lbr_chartabsize(wp, ptr, vcol, &head);
+	    incr = win_lbr_chartabsize(wp, ptr, vcol, &head, pos->lnum);
 	    /* make sure we don't go past the end of the line */
 	    if (*ptr == NUL)
 	    {
diff -r b89e2bdcc6e5 src/edit.c
--- a/src/edit.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/edit.c	Fri Jan 11 11:13:16 2013 -0600
@@ -405,7 +405,7 @@
 	if (startln)
 	    Insstart.col = 0;
     }
-    Insstart_textlen = (colnr_T)linetabsize(ml_get_curline());
+    Insstart_textlen = (colnr_T)linetabsize(ml_get_curline(), Insstart.lnum);
     Insstart_blank_vcol = MAXCOL;
     if (!did_ai)
 	ai_col = 0;
@@ -1913,7 +1913,7 @@
 	    else
 #endif
 		++new_cursor_col;
-	    vcol += lbr_chartabsize(ptr + new_cursor_col, (colnr_T)vcol);
+	    vcol += lbr_chartabsize(ptr + new_cursor_col, (colnr_T)vcol, curwin->w_cursor.lnum);
 	}
 	vcol = last_vcol;
 
@@ -6701,7 +6701,7 @@
 	    ins_need_undo = FALSE;
 	}
 	Insstart = curwin->w_cursor;	/* new insertion starts here */
-	Insstart_textlen = (colnr_T)linetabsize(ml_get_curline());
+	Insstart_textlen = (colnr_T)linetabsize(ml_get_curline(), curwin->w_cursor.lnum);
 	ai_col = 0;
 #ifdef FEAT_VREPLACE
 	if (State & VREPLACE_FLAG)
@@ -7056,9 +7056,10 @@
 	for (;;)
 	{
 	    coladvance(v - width);
-	    /* getviscol() is slow, skip it when 'showbreak' is empty and
-	     * there are no multi-byte characters */
-	    if ((*p_sbr == NUL
+	    /* getviscol() is slow, skip it when 'showbreak' is empty,
+	     * 'breakindent' is not set and there are no multi-byte
+	     * characters */
+	    if ((*p_sbr == NUL && !curwin->w_p_bri
 #  ifdef FEAT_MBYTE
 			&& !has_mbyte
 #  endif
@@ -9694,11 +9695,11 @@
 	getvcol(curwin, &fpos, &vcol, NULL, NULL);
 	getvcol(curwin, cursor, &want_vcol, NULL, NULL);
 
-	/* Use as many TABs as possible.  Beware of 'showbreak' and
+	/* Use as many TABs as possible.  Beware of 'breakindent', 'showbreak' and
 	 * 'linebreak' adding extra virtual columns. */
 	while (vim_iswhite(*ptr))
 	{
-	    i = lbr_chartabsize((char_u *)"\t", vcol);
+	    i = lbr_chartabsize((char_u *)"\t", vcol, cursor->lnum);
 	    if (vcol + i > want_vcol)
 		break;
 	    if (*ptr != TAB)
@@ -9724,7 +9725,7 @@
 	    /* Skip over the spaces we need. */
 	    while (vcol < want_vcol && *ptr == ' ')
 	    {
-		vcol += lbr_chartabsize(ptr, vcol);
+		vcol += lbr_chartabsize(ptr, vcol, cursor->lnum);
 		++ptr;
 		++repl_off;
 	    }
@@ -9980,7 +9981,7 @@
     while ((colnr_T)temp < curwin->w_virtcol && *ptr != NUL)
     {
 	prev_ptr = ptr;
-	temp += lbr_chartabsize_adv(&ptr, (colnr_T)temp);
+	temp += lbr_chartabsize_adv(&ptr, (colnr_T)temp, lnum);
     }
     if ((colnr_T)temp > curwin->w_virtcol)
 	ptr = prev_ptr;
diff -r b89e2bdcc6e5 src/eval.c
--- a/src/eval.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/eval.c	Fri Jan 11 11:13:16 2013 -0600
@@ -17381,8 +17381,11 @@
 
     if (argvars[1].v_type != VAR_UNKNOWN)
 	col = get_tv_number(&argvars[1]);
-
-    rettv->vval.v_number = (varnumber_T)(linetabsize_col(col, s) - col);
+    /*
+     * FIXME: passing 0 as 3rd argument to linetabsize_col, instead of real line number;
+     * (can we get it from here somehow?); might give incorrect result with breakindent!
+     */
+    rettv->vval.v_number = (varnumber_T)(linetabsize_col(col, s, 0) - col); 
 }
 
 /*
diff -r b89e2bdcc6e5 src/ex_cmds.c
--- a/src/ex_cmds.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/ex_cmds.c	Fri Jan 11 11:13:16 2013 -0600
@@ -261,7 +261,7 @@
 	;
     save = *last;
     *last = NUL;
-    len = linetabsize(line);		/* get line length */
+    len = linetabsize(line, curwin->w_cursor.lnum); /* get line length */
     if (has_tab != NULL)		/* check for embedded TAB */
 	*has_tab = (vim_strrchr(first, TAB) != NULL);
     *last = save;
diff -r b89e2bdcc6e5 src/getchar.c
--- a/src/getchar.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/getchar.c	Fri Jan 11 11:13:16 2013 -0600
@@ -2619,7 +2619,7 @@
 				    if (!vim_iswhite(ptr[col]))
 					curwin->w_wcol = vcol;
 				    vcol += lbr_chartabsize(ptr + col,
-							       (colnr_T)vcol);
+							       (colnr_T)vcol, curwin->w_cursor.lnum);
 #ifdef FEAT_MBYTE
 				    if (has_mbyte)
 					col += (*mb_ptr2len)(ptr + col);
diff -r b89e2bdcc6e5 src/gui_beval.c
--- a/src/gui_beval.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/gui_beval.c	Fri Jan 11 11:13:16 2013 -0600
@@ -335,7 +335,7 @@
 	{
 	    /* Not past end of the file. */
 	    lbuf = ml_get_buf(wp->w_buffer, lnum, FALSE);
-	    if (col <= win_linetabsize(wp, lbuf, (colnr_T)MAXCOL))
+	    if (col <= win_linetabsize(wp, lbuf, (colnr_T)MAXCOL, lnum))
 	    {
 		/* Not past end of line. */
 		if (getword)
diff -r b89e2bdcc6e5 src/misc1.c
--- a/src/misc1.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/misc1.c	Fri Jan 11 11:13:16 2013 -0600
@@ -465,6 +465,44 @@
     return (int)col;
 }
 
+#ifdef FEAT_LINEBREAK
+/* 
+ * Return appropriate space number for breakindent, taking influencing 
+ * parameters into account. Window must be specified, since it is not
+ * necessarily always the current one. If lnum==0, current line is calculated,
+ * specified line otherwise.
+ */
+   int
+get_breakindent_win (wp,lnum)
+    win_T*	wp;
+    linenr_T	lnum;
+{
+    int bri;
+    /* window width minus barren space, i.e. what rests for text */
+    const int eff_wwidth = W_WIDTH(wp)
+	- (wp->w_p_nu && !vim_strchr(p_cpo,CPO_NUMCOL)?number_width(wp):0);
+	/* - (*p_sbr == NUL ? 0 : vim_strsize(p_sbr)); */
+
+    bri = get_indent_buf(wp->w_buffer,lnum?lnum:wp->w_cursor.lnum) + wp->w_p_brishift;
+
+    /* if numbering and 'c' in 'cpoptions', cancel it out effectively */
+    /* (this could be replaced by an equivalent call to win_col_off2()) */
+    if (curwin->w_p_nu && vim_strchr(p_cpo, CPO_NUMCOL))
+	bri += number_width(wp);
+    
+    /* never indent past left window margin */
+    if (bri < 0)
+	bri = 0;
+    /* always leave at least bri_min characters on the left,
+     * if text width is sufficient */
+    else if (bri > eff_wwidth - wp->w_p_brimin)
+	bri = eff_wwidth - wp->w_p_brimin < 0 ? 0 : eff_wwidth - wp->w_p_brimin;
+
+    return bri;
+}
+#endif
+
+
 #if defined(FEAT_CINDENT) || defined(FEAT_SMARTINDENT)
 
 static int cin_is_cinword __ARGS((char_u *line));
@@ -1947,7 +1985,7 @@
     s = ml_get_buf(wp->w_buffer, lnum, FALSE);
     if (*s == NUL)		/* empty line */
 	return 1;
-    col = win_linetabsize(wp, s, (colnr_T)MAXCOL);
+    col = win_linetabsize(wp, s, (colnr_T)MAXCOL, lnum);
 
     /*
      * If list mode is on, then the '$' at the end of the line may take up one
@@ -2003,7 +2041,7 @@
     col = 0;
     while (*s != NUL && --column >= 0)
     {
-	col += win_lbr_chartabsize(wp, s, (colnr_T)col, NULL);
+	col += win_lbr_chartabsize(wp, s, (colnr_T)col, NULL, lnum);
 	mb_ptr_adv(s);
     }
 
@@ -2015,7 +2053,7 @@
      * 'ts') -- webb.
      */
     if (*s == TAB && (State & NORMAL) && (!wp->w_p_list || lcs_tab1))
-	col += win_lbr_chartabsize(wp, s, (colnr_T)col, NULL) - 1;
+	col += win_lbr_chartabsize(wp, s, (colnr_T)col, NULL, lnum) - 1;
 
     /*
      * Add column offset for 'number', 'relativenumber', 'foldcolumn', etc.
@@ -8972,7 +9010,7 @@
 		amount = 0;
 		while (*that && col)
 		{
-		    amount += lbr_chartabsize_adv(&that, (colnr_T)amount);
+		    amount += lbr_chartabsize_adv(&that, (colnr_T)amount, pos->lnum);
 		    col--;
 		}
 
@@ -8995,7 +9033,7 @@
 
 		    while (vim_iswhite(*that))
 		    {
-			amount += lbr_chartabsize(that, (colnr_T)amount);
+			amount += lbr_chartabsize(that, (colnr_T)amount, pos->lnum);
 			++that;
 		    }
 
@@ -9034,14 +9072,14 @@
 				    --parencount;
 				if (*that == '\\' && *(that+1) != NUL)
 				    amount += lbr_chartabsize_adv(&that,
-							     (colnr_T)amount);
+							     (colnr_T)amount, pos->lnum);
 				amount += lbr_chartabsize_adv(&that,
-							     (colnr_T)amount);
+							     (colnr_T)amount, pos->lnum);
 			    }
 			}
 			while (vim_iswhite(*that))
 			{
-			    amount += lbr_chartabsize(that, (colnr_T)amount);
+			    amount += lbr_chartabsize(that, (colnr_T)amount, pos->lnum);
 			    that++;
 			}
 			if (!*that || *that == ';')
diff -r b89e2bdcc6e5 src/misc2.c
--- a/src/misc2.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/misc2.c	Fri Jan 11 11:13:16 2013 -0600
@@ -166,7 +166,7 @@
 #ifdef FEAT_VIRTUALEDIT
 	    if ((addspaces || finetune) && !VIsual_active)
 	    {
-		curwin->w_curswant = linetabsize(line) + one_more;
+		curwin->w_curswant = linetabsize(line, pos->lnum) + one_more;
 		if (curwin->w_curswant > 0)
 		    --curwin->w_curswant;
 	    }
@@ -184,7 +184,7 @@
 # endif
 		&& wcol >= (colnr_T)width)
 	{
-	    csize = linetabsize(line);
+	    csize = linetabsize(line, pos->lnum);
 	    if (csize > 0)
 		csize--;
 
@@ -205,10 +205,10 @@
 	{
 	    /* Count a tab for what it's worth (if list mode not on) */
 #ifdef FEAT_LINEBREAK
-	    csize = win_lbr_chartabsize(curwin, ptr, col, &head);
+	    csize = win_lbr_chartabsize(curwin, ptr, col, &head, pos->lnum);
 	    mb_ptr_adv(ptr);
 #else
-	    csize = lbr_chartabsize_adv(&ptr, col);
+	    csize = lbr_chartabsize_adv(&ptr, col, pos->lnum);
 #endif
 	    col += csize;
 	}
diff -r b89e2bdcc6e5 src/normal.c
--- a/src/normal.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/normal.c	Fri Jan 11 11:13:16 2013 -0600
@@ -4495,7 +4495,7 @@
     int		dir;
     long	dist;
 {
-    int		linelen = linetabsize(ml_get_curline());
+    int		linelen = linetabsize(ml_get_curline(), curwin->w_cursor.lnum);
     int		retval = OK;
     int		atend = FALSE;
     int		n;
@@ -4568,7 +4568,7 @@
 		    (void)hasFolding(curwin->w_cursor.lnum,
 						&curwin->w_cursor.lnum, NULL);
 #endif
-		linelen = linetabsize(ml_get_curline());
+		linelen = linetabsize(ml_get_curline(), curwin->w_cursor.lnum);
 		if (linelen > width1)
 		    curwin->w_curswant += (((linelen - width1 - 1) / width2)
 								+ 1) * width2;
@@ -4598,7 +4598,7 @@
 		}
 		curwin->w_cursor.lnum++;
 		curwin->w_curswant %= width2;
-		linelen = linetabsize(ml_get_curline());
+		linelen = linetabsize(ml_get_curline(), curwin->w_cursor.lnum);
 	    }
 	}
       }
diff -r b89e2bdcc6e5 src/ops.c
--- a/src/ops.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/ops.c	Fri Jan 11 11:13:16 2013 -0600
@@ -431,7 +431,7 @@
 	}
 	for ( ; vim_iswhite(*bd.textstart); )
 	{
-	    incr = lbr_chartabsize_adv(&bd.textstart, (colnr_T)(bd.start_vcol));
+	    incr = lbr_chartabsize_adv(&bd.textstart, (colnr_T)(bd.start_vcol), curwin->w_cursor.lnum);
 	    total += incr;
 	    bd.start_vcol += incr;
 	}
@@ -491,7 +491,7 @@
 
 	while (vim_iswhite(*non_white))
 	{
-	    incr = lbr_chartabsize_adv(&non_white, non_white_col);
+	    incr = lbr_chartabsize_adv(&non_white, non_white_col, curwin->w_cursor.lnum);
 	    non_white_col += incr;
 	}
 
@@ -516,7 +516,7 @@
 	    verbatim_copy_width -= bd.start_char_vcols;
 	while (verbatim_copy_width < destination_col)
 	{
-	    incr = lbr_chartabsize(verbatim_copy_end, verbatim_copy_width);
+	    incr = lbr_chartabsize(verbatim_copy_end, verbatim_copy_width, curwin->w_cursor.lnum);
 	    if (verbatim_copy_width + incr > destination_col)
 		break;
 	    verbatim_copy_width += incr;
@@ -3598,7 +3598,7 @@
 	    for (ptr = oldp; vcol < col && *ptr; )
 	    {
 		/* Count a tab for what it's worth (if list mode not on) */
-		incr = lbr_chartabsize_adv(&ptr, (colnr_T)vcol);
+		incr = lbr_chartabsize_adv(&ptr, (colnr_T)vcol, lnum);
 		vcol += incr;
 	    }
 	    bd.textcol = (colnr_T)(ptr - oldp);
@@ -3632,7 +3632,7 @@
 	    /* calculate number of spaces required to fill right side of block*/
 	    spaces = y_width + 1;
 	    for (j = 0; j < yanklen; j++)
-		spaces -= lbr_chartabsize(&y_array[i][j], 0);
+		spaces -= lbr_chartabsize(&y_array[i][j], 0, lnum);
 	    if (spaces < 0)
 		spaces = 0;
 
@@ -5149,7 +5149,7 @@
     while (bdp->start_vcol < oap->start_vcol && *pstart)
     {
 	/* Count a tab for what it's worth (if list mode not on) */
-	incr = lbr_chartabsize(pstart, (colnr_T)bdp->start_vcol);
+	incr = lbr_chartabsize(pstart, (colnr_T)bdp->start_vcol, lnum);
 	bdp->start_vcol += incr;
 #ifdef FEAT_VISUALEXTRA
 	if (vim_iswhite(*pstart))
@@ -5218,7 +5218,7 @@
 	    {
 		/* Count a tab for what it's worth (if list mode not on) */
 		prev_pend = pend;
-		incr = lbr_chartabsize_adv(&pend, (colnr_T)bdp->end_vcol);
+		incr = lbr_chartabsize_adv(&pend, (colnr_T)bdp->end_vcol, lnum);
 		bdp->end_vcol += incr;
 	    }
 	    if (bdp->end_vcol <= oap->end_vcol
@@ -6714,7 +6714,7 @@
 	    validate_virtcol();
 	    col_print(buf1, sizeof(buf1), (int)curwin->w_cursor.col + 1,
 		    (int)curwin->w_virtcol + 1);
-	    col_print(buf2, sizeof(buf2), (int)STRLEN(p), linetabsize(p));
+	    col_print(buf2, sizeof(buf2), (int)STRLEN(p), linetabsize(p, curwin->w_cursor.lnum));
 
 	    if (char_count_cursor == byte_count_cursor
 		    && char_count == byte_count)
diff -r b89e2bdcc6e5 src/option.c
--- a/src/option.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/option.c	Fri Jan 11 11:13:16 2013 -0600
@@ -187,6 +187,11 @@
 #ifdef FEAT_ARABIC
 # define PV_ARAB	OPT_WIN(WV_ARAB)
 #endif
+#ifdef FEAT_LINEBREAK
+# define PV_BRI		OPT_WIN(WV_BRI)
+# define PV_BRIMIN	OPT_WIN(WV_BRIMIN)
+# define PV_BRISHIFT	OPT_WIN(WV_BRISHIFT)
+#endif
 #ifdef FEAT_DIFF
 # define PV_DIFF	OPT_WIN(WV_DIFF)
 #endif
@@ -646,6 +651,33 @@
 			    {(char_u *)0L, (char_u *)0L}
 #endif
 			    SCRIPTID_INIT},
+    {"breakindent",   "bri",  P_BOOL|P_VI_DEF|P_VIM|P_RWIN,
+#ifdef FEAT_LINEBREAK
+			    (char_u *)VAR_WIN, PV_BRI,
+			    {(char_u *)FALSE, (char_u *)0L}
+#else
+			    (char_u *)NULL, PV_NONE,
+			    {(char_u *)0L, (char_u *)0L}
+#endif
+			    SCRIPTID_INIT},
+    {"breakindentmin", "brimin", P_NUM|P_VI_DEF|P_VIM|P_RWIN,
+#ifdef FEAT_LINEBREAK
+			    (char_u *)VAR_WIN, PV_BRIMIN,
+			    {(char_u *)20L, (char_u *)20L}
+#else
+			    (char_u *)NULL, PV_NONE,
+			    {(char_u *)0L, (char_u *)0L}
+#endif
+			    SCRIPTID_INIT},
+    {"breakindentshift", "brishift", P_NUM|P_VI_DEF|P_VIM|P_RWIN,
+#ifdef FEAT_LINEBREAK
+			    (char_u *)VAR_WIN, PV_BRISHIFT,
+			    {(char_u *)0L, (char_u *)0L}
+#else
+			    (char_u *)NULL, PV_NONE,
+			    {(char_u *)0L, (char_u *)0L}
+#endif
+			    SCRIPTID_INIT},
     {"browsedir",   "bsdir",P_STRING|P_VI_DEF,
 #ifdef FEAT_BROWSE
 			    (char_u *)&p_bsdir, PV_NONE,
@@ -8429,6 +8461,16 @@
 	}
 	curwin->w_nrwidth_line_count = 0;
     }
+
+    /* 'breakindentmin' must be positive */
+    else if (pp == &curwin->w_p_brimin)
+    {
+	if (curwin->w_p_brimin < 1)
+	{
+	    errmsg = e_positive;
+	    curwin->w_p_brimin = 1;
+	}
+    }
 #endif
 
     else if (pp == &curbuf->b_p_tw)
@@ -9661,6 +9703,9 @@
 	case PV_WRAP:	return (char_u *)&(curwin->w_p_wrap);
 #ifdef FEAT_LINEBREAK
 	case PV_LBR:	return (char_u *)&(curwin->w_p_lbr);
+	case PV_BRI:	return (char_u *)&(curwin->w_p_bri);
+	case PV_BRIMIN:	return (char_u *)&(curwin->w_p_brimin);
+	case PV_BRISHIFT: return (char_u *)&(curwin->w_p_brishift);
 #endif
 #ifdef FEAT_SCROLLBIND
 	case PV_SCBIND: return (char_u *)&(curwin->w_p_scb);
@@ -9847,6 +9892,8 @@
     to->wo_wrap = from->wo_wrap;
 #ifdef FEAT_LINEBREAK
     to->wo_lbr = from->wo_lbr;
+    to->wo_bri = from->wo_bri;
+    to->wo_brimin = from->wo_brimin;
 #endif
 #ifdef FEAT_SCROLLBIND
     to->wo_scb = from->wo_scb;
diff -r b89e2bdcc6e5 src/option.h
--- a/src/option.h	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/option.h	Fri Jan 11 11:13:16 2013 -0600
@@ -1049,6 +1049,11 @@
 #ifdef FEAT_CURSORBIND
     , WV_CRBIND
 #endif
+#ifdef FEAT_LINEBREAK
+    , WV_BRI
+    , WV_BRIMIN
+    , WV_BRISHIFT
+#endif
 #ifdef FEAT_DIFF
     , WV_DIFF
 #endif
diff -r b89e2bdcc6e5 src/proto/charset.pro
--- a/src/proto/charset.pro	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/proto/charset.pro	Fri Jan 11 11:13:16 2013 -0600
@@ -14,9 +14,9 @@
 int vim_strsize __ARGS((char_u *s));
 int vim_strnsize __ARGS((char_u *s, int len));
 int chartabsize __ARGS((char_u *p, colnr_T col));
-int linetabsize __ARGS((char_u *s));
-int linetabsize_col __ARGS((int startcol, char_u *s));
-int win_linetabsize __ARGS((win_T *wp, char_u *p, colnr_T len));
+int linetabsize __ARGS((char_u *s, linenr_T lnum));
+int linetabsize_col __ARGS((int startcol, char_u *s, linenr_T lnum));
+int win_linetabsize __ARGS((win_T *wp, char_u *p, colnr_T len, linenr_T lnum));
 int vim_isIDc __ARGS((int c));
 int vim_iswordc __ARGS((int c));
 int vim_iswordp __ARGS((char_u *p));
@@ -25,9 +25,9 @@
 int vim_isfilec_or_wc __ARGS((int c));
 int vim_isprintc __ARGS((int c));
 int vim_isprintc_strict __ARGS((int c));
-int lbr_chartabsize __ARGS((unsigned char *s, colnr_T col));
-int lbr_chartabsize_adv __ARGS((char_u **s, colnr_T col));
-int win_lbr_chartabsize __ARGS((win_T *wp, char_u *s, colnr_T col, int *headp));
+int lbr_chartabsize __ARGS((unsigned char *s, colnr_T col, linenr_T lnum));
+int lbr_chartabsize_adv __ARGS((char_u **s, colnr_T col, linenr_T lnum));
+int win_lbr_chartabsize __ARGS((win_T *wp, char_u *s, colnr_T col, int *headp, linenr_T lnum));
 int in_win_border __ARGS((win_T *wp, colnr_T vcol));
 void getvcol __ARGS((win_T *wp, pos_T *pos, colnr_T *start, colnr_T *cursor, colnr_T *end));
 colnr_T getvcol_nolist __ARGS((pos_T *posp));
diff -r b89e2bdcc6e5 src/proto/misc1.pro
--- a/src/proto/misc1.pro	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/proto/misc1.pro	Fri Jan 11 11:13:16 2013 -0600
@@ -5,6 +5,7 @@
 int get_indent_str __ARGS((char_u *ptr, int ts));
 int set_indent __ARGS((int size, int flags));
 int get_number_indent __ARGS((linenr_T lnum));
+int get_breakindent_win __ARGS((win_T *wp, linenr_T lnum));
 int open_line __ARGS((int dir, int flags, int second_line_indent));
 int get_leader_len __ARGS((char_u *line, char_u **flags, int backward, int include_space));
 int get_last_leader_offset __ARGS((char_u *line, char_u **flags));
diff -r b89e2bdcc6e5 src/regexp.c
--- a/src/regexp.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/regexp.c	Fri Jan 11 11:13:16 2013 -0600
@@ -4269,7 +4269,7 @@
 		    if (top.col == MAXCOL || bot.col == MAXCOL)
 			end = MAXCOL;
 		    cols = win_linetabsize(wp,
-				      regline, (colnr_T)(reginput - regline));
+				      regline, (colnr_T)(reginput - regline), reglnum + reg_firstlnum);
 		    if (cols < start || cols > end - (*p_sel == 'e'))
 			status = RA_NOMATCH;
 		}
@@ -4293,7 +4293,7 @@
 	  case RE_VCOL:
 	    if (!re_num_cmp((long_u)win_linetabsize(
 			    reg_win == NULL ? curwin : reg_win,
-			    regline, (colnr_T)(reginput - regline)) + 1, scan))
+			    regline, (colnr_T)(reginput - regline), reglnum + reg_firstlnum ) + 1, scan))
 		status = RA_NOMATCH;
 	    break;
 
diff -r b89e2bdcc6e5 src/screen.c
--- a/src/screen.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/screen.c	Fri Jan 11 11:13:16 2013 -0600
@@ -2815,10 +2815,15 @@
 # define WL_SIGN	WL_FOLD		/* column for signs */
 #endif
 #define WL_NR		WL_SIGN + 1	/* line number */
+#ifdef FEAT_LINEBREAK
+# define WL_BRI		WL_NR + 1	/* 'breakindent' */
+#else
+# define WL_BRI		WL_NR
+#endif
 #if defined(FEAT_LINEBREAK) || defined(FEAT_DIFF)
-# define WL_SBR		WL_NR + 1	/* 'showbreak' or 'diff' */
+# define WL_SBR		WL_BRI + 1	/* 'showbreak' or 'diff' */
 #else
-# define WL_SBR		WL_NR
+# define WL_SBR		WL_BRI
 #endif
 #define WL_LINE		WL_SBR + 1	/* text in the line */
     int		draw_state = WL_START;	/* what to draw next */
@@ -3149,7 +3154,7 @@
 #endif
 	while (vcol < v && *ptr != NUL)
 	{
-	    c = win_lbr_chartabsize(wp, ptr, (colnr_T)vcol, NULL);
+	    c = win_lbr_chartabsize(wp, ptr, (colnr_T)vcol, NULL, lnum);
 	    vcol += c;
 #ifdef FEAT_MBYTE
 	    prev_ptr = ptr;
@@ -3519,6 +3524,30 @@
 		}
 	    }
 
+#ifdef FEAT_LINEBREAK 
+	    /* draw 'breakindent': indent wrapped text accordingly */
+	    if (draw_state == WL_BRI -1 && n_extra == 0){
+		draw_state = WL_BRI;
+# ifdef FEAT_DIFF
+		/* FIXME: handle (filler_todo > 0): or modify showbreak so that ---- lines are shorter by the amount needed? */
+# endif
+		if (wp->w_p_bri && row != startrow){ /* FIXME: what is startrow? Don't we need it as well?? */
+		    p_extra = NUL;
+		    c_extra = ' ';
+		    n_extra = get_breakindent_win(wp,lnum);
+		    char_attr = 0; /* was: hl_attr(HLF_AT); */
+		    /* FIXME: why do we need to adjust vcol if showbreak does not?? */
+		    // vcol += n_extra;
+		    /* FIXME: is this relevant here? copied shamelessly from showbreak */
+		    /* Correct end of highlighted area for 'breakindent',
+		     * required when 'linebreak' is also set. */
+		    if (tocol == vcol)
+			tocol += n_extra;
+		}
+	    }
+#endif
+	    
+
 #if defined(FEAT_LINEBREAK) || defined(FEAT_DIFF)
 	    if (draw_state == WL_SBR - 1 && n_extra == 0)
 	    {
@@ -4225,7 +4254,7 @@
 # ifdef FEAT_MBYTE
 				has_mbyte ? mb_l :
 # endif
-				1), (colnr_T)vcol, NULL) - 1;
+				1), (colnr_T)vcol, NULL, lnum) - 1;
 		    c_extra = ' ';
 		    if (vim_iswhite(c))
 			c = ' ';
diff -r b89e2bdcc6e5 src/structs.h
--- a/src/structs.h	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/structs.h	Fri Jan 11 11:13:16 2013 -0600
@@ -133,6 +133,14 @@
     int		wo_arab;
 # define w_p_arab w_onebuf_opt.wo_arab	/* 'arabic' */
 #endif
+#ifdef FEAT_LINEBREAK
+    int		wo_bri;
+# define w_p_bri w_onebuf_opt.wo_bri	/* 'breakindent' */
+    long	wo_brimin;
+# define w_p_brimin w_onebuf_opt.wo_brimin /* 'breakindentmin' */
+    long	wo_brishift;
+# define w_p_brishift w_onebuf_opt.wo_brishift /* 'breakindentshift' */
+#endif
 #ifdef FEAT_DIFF
     int		wo_diff;
 # define w_p_diff w_onebuf_opt.wo_diff	/* 'diff' */
diff -r b89e2bdcc6e5 src/ui.c
--- a/src/ui.c	Sun Dec 16 12:50:40 2012 +0100
+++ b/src/ui.c	Fri Jan 11 11:13:16 2013 -0600
@@ -3134,7 +3134,7 @@
     start = ptr = ml_get_buf(wp->w_buffer, lnum, FALSE);
     while (count < vcol && *ptr != NUL)
     {
-	count += win_lbr_chartabsize(wp, ptr, count, NULL);
+	count += win_lbr_chartabsize(wp, ptr, count, NULL, lnum);
 	mb_ptr_adv(ptr);
     }
     return (int)(ptr - start);
