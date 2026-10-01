import pandas as pd
def table_desc_regions(variables_hh_dict, variables_ind_dict, list_regions, suffix=''):
	'''
	Generate a table with descriptives
	'''

	dict_dfs={}
	dict_dfs['hh']={}
	dict_dfs['ind_m']={}
	dict_dfs['ind_w']={}
	dict_dfs['ind_nobs']={}
	for r in list_regions:
		dict_dfs['hh'][r]=pd.read_stata('../../bld/data/descriptives/desc_stats_hh_'+r+'.dta', index_col='couple_type')
		dict_dfs['ind_m'][r]=pd.read_stata('../../bld/data/descriptives/desc_stats_individual_'+r+'_men.dta', index_col='couple_type')
		dict_dfs['ind_w'][r]=pd.read_stata('../../bld/data/descriptives/desc_stats_individual_'+r+'_women.dta', index_col='couple_type')
		dict_dfs['ind_nobs'][r]=pd.read_stata('../../bld/data/descriptives/desc_stats_individual_'+r+'_nobs.dta', index_col='couple_type')

	# Table 3: household descriptive-statistics fragments
	with open('../../bld/tables/desc_stats_hh'+ suffix + '.tex', 'w') as fw:
		for k in variables_hh_dict.keys():
			linew=variables_hh_dict[k]
			for r in dict_dfs['hh'].keys():
				for c in ['Different-sex couple','Same-sex couple: men',
					'Same-sex couple: women']:
					if k not in ['hours_worked']:
						linew+= " & " + "%.2f" % (100*dict_dfs['hh'][r].loc[c,k]) + "\\%"
					else:
						linew+= " & " + "%.2f" % dict_dfs['hh'][r].loc[c,k]
			linew+= '\\\ \n'
			fw.write(linew)

	# Table 3: mens individual descriptive-statistics fragments
	with open('../../bld/tables/desc_stats_individual_men'+ suffix + '.tex', 'w') as fw:
		for k in variables_ind_dict.keys():
			linew=variables_ind_dict[k]
			for r in dict_dfs['ind_m'].keys():
				for c in ['Different-sex couple','Same-sex couple: men',
				'Same-sex couple: women']:
					if c in dict_dfs['ind_m'][r].index:
						if k not in ['age']:
							linew+= " & " + "%.2f" % (100*dict_dfs['ind_m'][r].loc[c,k])  + "\\%"
						else:
							linew+= " & " + "%.2f" % dict_dfs['ind_m'][r].loc[c,k]
					else:
						linew+= " & "
			linew+= '\\\ \n'
			fw.write(linew)

	# Table 3: womens individual descriptive-statistics fragments
	with open('../../bld/tables/desc_stats_individual_women'+ suffix + '.tex', 'w') as fw:
		for k in variables_ind_dict.keys():
			linew=variables_ind_dict[k]
			for r in dict_dfs['ind_w'].keys():
				for c in ['Different-sex couple','Same-sex couple: men',
				'Same-sex couple: women']:
					if c in dict_dfs['ind_w'][r].index:
						if k not in ['age']:
							linew+= " & " + "%.2f" % (100*dict_dfs['ind_w'][r].loc[c,k]) + "\\%"
						else:
							linew+= " & " + "%.2f" % dict_dfs['ind_w'][r].loc[c,k]
					else:
						linew+= " & "
			linew+= '\\\ \n'
			fw.write(linew)
	# Table 3: individual observation-count fragments
	with open('../../bld/tables/desc_stats_individual_nobs'+ suffix + '.tex', 'w') as fw:
		linew1="Observations"
		linew2="Share"
		for r in dict_dfs['ind_nobs'].keys():
			sum_weight = 0
			for c in ['Different-sex couple','Same-sex couple: men',
				'Same-sex couple: women']:
				linew1+= " & " + '{:>12,.0f}'.format(dict_dfs['ind_nobs'][r].loc[c,'count'])
				sum_weight+=dict_dfs['ind_nobs'][r].loc[c,'weight_pop']
			for c in ['Different-sex couple','Same-sex couple: men',
				'Same-sex couple: women']:
				linew2+= " & " + "%.2f" % (100*dict_dfs['ind_nobs'][r].loc[c,'weight_pop']/sum_weight) + "\\%"			
		linew1+= '\\\ \n'
		fw.write(linew1)
		fw.write(linew2)


hh_vars_d={'labor_force': 'Labor Force Participation (both)', 
'hours_worked': 'Hours Worked', 'hh_age_0_14_d': 'Children (dummy)'}

ind_vars_d={'unemp': 'Unemployment', 'age':'Age', 
'edu_secondary': 'Secondary Education', 'edu_tertiary': 'Tertiary Education'}

# Table 3: Descriptive statistics (country panels 1 and 2)
table_desc_regions(variables_hh_dict=hh_vars_d, variables_ind_dict=ind_vars_d, list_regions=['BEL', 'BRA', 'FRA', 'DEU'], suffix='_cntry1')
table_desc_regions(variables_hh_dict=hh_vars_d, variables_ind_dict=ind_vars_d, list_regions=['NLD', 'GBR', 'USA', 'URY'], suffix='_cntry2')
