import pandas as pd
def country_pop_share(country, dict_r_y):
	''' Generate a dict of country's population
	with same-sex marriage
	'''
	years_list=list(range(2000,2023))
	dict_fin={}
	dict_cum = {}
	list_already=[]
	for y in years_list:
		if y in dict_r_y.keys():
			if dict_r_y[y]!=1 and list_already!=1:
				list_already+=dict_r_y[y]
				dict_cum[y]=[x for x in list_already]
			else:
				list_already=1
				dict_cum[y]=1
		else:
			if list_already!=1:
				dict_cum[y]=[x for x in list_already]
			else:
				dict_cum[y]=1
	if country=="MEX":
		df_in = pd.read_excel("../../data/raw/population_totals/Poblacion_01.xlsx", skiprows=6, header=None)
		df_in = df_in.rename(columns={0: 'region', 4: 'pop_2010'})
		sum_2010=df_in['pop_2010'].sum()
		for y in years_list:
			if dict_cum[y]!=1:
				df_y_r = df_in[df_in['region'].isin(dict_cum[y])]
				dict_fin[y] =   df_y_r['pop_2010'].sum()/sum_2010
			else:
				dict_fin[y] =1
	elif country=="USA":
		df_in = pd.read_excel("../../data/raw/population_totals/popest-annual.xls", skiprows=12, header=None, sheet_name='States')
		df_in = df_in.rename(columns={1: 'region', 2: 'pop_2010'})
		sum_2010=df_in['pop_2010'].sum()
		for y in years_list:
			if dict_cum[y]!=1:
				df_y_r = df_in[df_in['region'].isin(dict_cum[y])]
				dict_fin[y] =   df_y_r['pop_2010'].sum()/sum_2010
			else:
				dict_fin[y] =1		
	elif country=="GBR":
		for y in range(2000,2014):
			dict_fin[y]=0
		for y in range(2014,2021):
			dict_fin[y]=61371000/63182000
		for y in range(2021,2023):
			dict_fin[y]=1
	elif country=="CAN":
		df_in = pd.read_csv('../../data/raw/population_totals/1710000901-noSymbol.csv', skiprows=range(0, 12), nrows=13, thousands=',', header=None)
		df_in = df_in.rename(columns={0: 'region', 1: 'pop_2000'})
		sum_2000=df_in['pop_2000'].sum()
		for y in years_list:
			if dict_cum[y]!=1:
				df_y_r = df_in[df_in['region'].isin(dict_cum[y])]
				dict_fin[y] =   df_y_r['pop_2000'].sum()/sum_2000
			else:
				dict_fin[y] =1	
	elif country=="BRA":
		df_in = pd.read_excel("../../data/raw/population_totals/serie_2001_2015_TCU.xls", skiprows=6, header=None, sheet_name='Plan1')
		df_in = df_in.rename(columns={0: 'region', 10: 'pop_2010'})
		sum_2010=df_in.loc[df_in['region']=="Brasil",'pop_2010'].sum()
		for y in years_list:
			if dict_cum[y]!=1:
				df_y_r = df_in[df_in['region'].isin(dict_cum[y])]
				dict_fin[y] =   df_y_r['pop_2010'].sum()/sum_2010
			else:
				dict_fin[y] =1		
	return dict_fin

def population_samesex_marriage_world(dict_r_y, dict_c_y, list_c_all, list_c_fin, file_out, years):
	'''
	'''
	df_final=pd.DataFrame(index=years, columns=['pop_world', 'pop_ssm','pop_data_all','pop_data_fin'])
	df_final.index.names=['year']
	for c in ['pop_ssm','pop_data_all','pop_data_fin']:
		df_final.loc[2000,c]=0
	dict_c_cum={}
	list_already=[]
	for y in years:
		if y in dict_c_y.keys():
			list_already+=dict_c_y[y]
			dict_c_cum[y]=[x for x in list_already]
		else:
			dict_c_cum[y]=[x for x in list_already]
	df_in_pop=pd.read_csv('../../data/raw/population_totals/P_Data_Extract_From_World_Development_Indicators/69e1ed3e-833e-444c-b892-93ce505de507_Data.csv', na_values=['..'])
	dict_shares={}
	for c in ['MEX', 'USA', 'GBR', 'CAN', 'BRA']:
		dict_shares[c]=country_pop_share(country=c, dict_r_y=dicts_regions[c])	

	for y in years:
		if str(y)+ ' [YR' + str(y) + ']' in df_in_pop.columns:
			df_in_pop[str(y)+ ' [YR' + str(y) + ']'] = df_in_pop[str(y)+ ' [YR' + str(y) + ']'].astype(float)
			df_in_pop['share_' + str(y)]=0
			df_in_pop.loc[df_in_pop['Country Code'].isin(dict_c_cum[y]), 'share_' + str(y)]=1
			for c in dict_shares:
				df_in_pop.loc[df_in_pop['Country Code']==c, 'share_' + str(y)]=dict_shares[c][y]
			df_in_pop['pop_ssm']=df_in_pop[str(y)+ ' [YR' + str(y) + ']']*df_in_pop['share_' + str(y)]
			df_final.loc[y,'pop_ssm']=df_in_pop['pop_ssm'].sum()
			df_final.loc[y,'pop_data_all']=df_in_pop.loc[df_in_pop['Country Code'].isin(list_c_all),'pop_ssm'].sum()
			df_final.loc[y,'pop_data_fin']=df_in_pop.loc[df_in_pop['Country Code'].isin(list_c_fin),'pop_ssm'].sum()
			df_final.loc[y,'pop_world']=df_in_pop.loc[df_in_pop['Country Code']=='WLD', str(y)+ ' [YR' + str(y) + ']'].sum()
	for c in df_final.columns:
		df_final[c]=df_final[c]/1000000
	# Figure 1: source series for the final Stata figure
	df_final.to_csv(file_out)





dicts_regions={}

dicts_regions['MEX']={2010:['Ciudad de MÃ©xico'], 2012:['Quintana Roo'], 
2014:['Coahuila de Zaragoza'], 2015:['Chihuahua', 'Nayarit'],
2016:['Campeche', 'Colima', 'Jalisco', 'MichoacÃ¡n de Ocampo',
'Morelos'], 2017:['Baja California'], 2018:['Chiapas', 'Oaxaca', 'Puebla'],
2019: ['Aguascalientes', 'Baja California Sur', 'Hidalgo', 'Nuevo LeÃ³n',
'San Luis PotosÃ­'], 2020: ['Tlaxcala'], 2021: ['Guanajuato',
'QuerÃ©taro', 'Sinaloa', 'Sonora', 'Zacatecas'],
2022:1}

dicts_regions['USA']={2004:['Massachusetts'], 2008:['Connecticut'],
2009:['Iowa', 'Vermont'], 2010:['New Hampshire', 'District of Columbia'],
2011:['New York'], 2012:['Maine', 'Washington'],
2013:['California', 'Delaware', 'Hawaii', 'Maryland',
'Minnesota', 'New Jersey', 'New Mexico', 'Rhode Island'],
2014:['Alaska', 'Arizona', 'Colorado', 'Idaho', 'Illinois',
'Indiana', 'Montana', 'Nevada', 'North Carolina', 'Oklahoma',
'Oregon', 'Pennsylvania', 'South Carolina', 'Utah', 
'Virginia', 'West Virginia', 'Wisconsin', 'Wyoming'], 2015:1}

dicts_regions['GBR']={2014:['England', 'Wales', 'Scotland'], 2020:1}

dicts_regions['CAN']={2003:['Ontario', 'British Columbia'], 
2004:['Quebec', 'Yukon', 'Manitoba', 'Nova Scotia', 'Saskatchewan',
'Newfoundland and Labrador'], 2005:1}

dicts_regions['BRA']={2011:['Alagoas'], 2012:['Sergipe', 'EspÃ­rito Santo',
'Bahia', 'Distrito Federal', 'PiauÃ­', 'SÃ£o Paulo'], 2013:1}

dict_countries={2001:['NLD'], 2003:['BEL'], 2005:['ESP'],
2006:['ZAF'],2009:['NOR', 'SWE'], 2010:['ARG', 'ISL', 'PRT'],
2012:['DNK'],2013:['FRA', 'NZL', 'URY'], 2015:['LUX', 'IRL'],
2016:['GRL', 'COL'], 2017:['FIN', 'DEU', 'AUS', 'MLT'],
2019:['AUT', 'ECU'], 2020:['CRI'],2022:['CHL', 'CUB',
'CHE', 'SVN']}

countries_data_all=['ARG', 'BRA', 'BEL', 'NLD', 'GBR', 'USA',
'MEX', 'FRA', 'IRL', 'COL', 'DEU', 'ZAF', 'URY', 'ESP',
'SWE', 'PRT', 'DNK', 'LUX', 'FIN', 'MLT', 'AUT','SVN']


countries_data_fin=['BRA', 'URY', 'BEL', 'NLD', 'GBR',
'FRA', 'DEU', 'USA']





# Figure 1 input: population series used by the final Stata graph
population_samesex_marriage_world(dict_r_y=dicts_regions, dict_c_y=dict_countries, 
	list_c_all=countries_data_all, list_c_fin=countries_data_fin,
	file_out="../../bld/data/population_samesex_marriage_world.csv", years=range(2000,2022))

