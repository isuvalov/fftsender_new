function res=search_maximums(x,start,stop)

	[pval,ppos]=max(x(start:stop));
	res=ppos;