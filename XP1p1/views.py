##views.py
##-------------------------------
## packages

from __future__ import division
import numpy
import collections
from otree.common import Currency as c, currency_range, safe_json
from django import template
from . import models
from ._builtin import Page, WaitPage
from otree.common import safe_json
from .models import Constants
register = template.Library()

##-------------------------------
class Introduction(Page):

    timeout_seconds = 160

    def vars_for_template(self):
        return {'image_path': Constants.xp_name}


    def is_displayed(self):
        return self.subsession.round_number == 1

##-------------------------------
class Form(Page):

    timeout_seconds = 120

    ##-------------------------------
    ## condition to display page
    def is_displayed(self):
        return self.subsession.round_number == 1

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
       data = {}
       return data

    ##-------------------------------
    ## form set up
    form_model = models.Player
    form_fields = ['name', 'age','profession','playAs']


##-------------------------------
class Form_WaitPage(WaitPage):

    def after_all_players_arrive(self):

        #set biomass
        self.group.set_biomass()

        # set Blim & uncertainty
        self.group.set_Un_Blim()

        ##if self.group.b_round <= 0:
        #    self.group.end()

##-------------------------------
class Catch_Pledge(Page):

    timeout_seconds = 60

    def is_displayed(self):
        return self.group.b_round > 0

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
        var = self.group.variation()
        j = range(0,len(Constants.choice_catch))
        r = range(0,len(Constants.other_choice_catch))

        tab_payoff = self.group.set_payoffTable()
        choice = "0:%d" % (Constants.elementPayoff_Tab)

        year = self.group.year()
        name = self.player.in_round(1).name

        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        data = {'Payoff': tab_payoff , 'round.number': self.subsession.round_number, 'biomass': self.group.b_round,
                'choicevar': choice,'variation':var,'j': j,'r': r,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label,
                'bround': self.group.b_round,
                'MyName': name,
                'MyID': self.player.id_in_group,
                'Year': year,
                'Round':self.subsession.round_number
                }

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass', 'data': biomass})

        data['seriesBlim_min'].append({'name': 'Blim_min',
                                       'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return data

    ##-------------------------------
    ## form set up
    form_model = models.Player
    form_fields = ['other_choice','catch_pledge']


##-------------------------------
class Pledge_WaitPage(WaitPage):

    def is_displayed(self):
        return self.group.b_round > 0

    def after_all_players_arrive(self):

       return()

##-------------------------------
class Pledge_Results(Page):
    ##-------------------------------
    ## variables for template

    timeout_seconds = 30

    def is_displayed(self):
        return self.group.b_round > 0

    def vars_for_template(self):

     name = self.player.in_round(1).name

     if self.group.b_round > 0:
        var = self.group.variation()
        j = range(0,len(Constants.choice_catch))
        r = range(0,len(Constants.other_choice_catch))

        pledge_round = []
        pledge_ID    = []
        pledge_data  = []

        for p in self.group.get_players():
            pledge_round.append(p. catch_pledge)
            pledge_ID.append(p.id_in_group)

        data = {'Player': pledge_ID, 'pledge': pledge_round}
        data = collections.OrderedDict(sorted(data.items(), key=lambda t: t[0]))

        for element, value in data.items():
            pledge_data.append(value)

        return {'data':data,'MyID':self.player.id_in_group, 'nation': pledge_data[0], 'pledge': pledge_data[1], 'variation':var, 'j': j,'r':r,
                'MyName':name}

##-------------------------------
class Catch_Choice(Page):

    timeout_seconds = 60

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):

        var = self.group.variation()
        j = range(0, len(Constants.choice_catch))
        r = range(0, len(Constants.other_choice_catch))
        tab_payoff = self.group.set_payoffTable()
        choice = "0:%d" % (Constants.elementPayoff_Tab)

        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        data = {'Payoff': tab_payoff, 'round.number': self.subsession.round_number, 'biomass': self.group.b_round,
                'choicevar': choice,'variation':var, 'j': j,'r':r,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass','data': biomass})

        data['seriesBlim_min'].append({'name': 'Blim_min',
                                       'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return data

    ##-------------------------------
    ## form set up
    form_model = models.Player
    form_fields = ['catch_choice']

##-------------------------------
class CatchChoice_WaitPage(WaitPage):

    def after_all_players_arrive(self):
            self.group.set_payoffs()
            if self.group.b_round > 0:
                self.group.projection()
                self.group.projUncertainty()

##-------------------------------
class Catch_Results(Page):

    timeout_seconds = 120

    def is_displayed(self):
        return self.group.b_round > 0

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
        # Filling the data for graph

        ## Catch, profit total and by player for each round
        catch_round = []
        totalCatch_round = []
        totalIndCatch = []
        profit_round = []
        totalProfit_round =  []
        totalIndProfit = []
        oCatch = []
        oProfit = []
        oID = []
        oData =[]

        # own cacth & profit per player
        for p in self.player.in_all_rounds():
            catch_round.append(p.catch_choice)
            profit_round.append(p.profit)
            totalIndCatch = sum(catch_round)
            totalIndProfit = sum(profit_round)

        # others cacth & profit per player
        for p in self.player.get_others_in_group():
                oCatch.append(p.catch_choice)
                oProfit.append(p.profit)
                oID.append(p.id_in_group)

        others_data = {'Player':oID, 'catch':oCatch, 'profit':oProfit}
        others_data = collections.OrderedDict(sorted(others_data .items(), key=lambda t: t[0]))

        for element, value in others_data.items():
            oData.append(value)

        # total harvest & total profit
        for p in self.group.in_all_rounds():
            totalCatch_round.append(p.total_catch)
            totalProfit_round.append(p.total_profit)

        # gather data to make series
        data = {'Player': self.player.id_in_group, 'Catch': catch_round,'Profit': profit_round,
                'TotalIndCatch':totalIndCatch,'TotalIndProfit':totalIndProfit,
                'Total_catch':  totalCatch_round, 'Total_profit':  totalProfit_round}

        # create series to plot
        seriesCatch=[]
        seriesCatch.append({'name': 'Own Catch', 'data': catch_round})
        seriesCatch.append({'name':'Total Catch', 'data': totalCatch_round})
        Catchseries = safe_json(seriesCatch)

        seriesProfit = []
        seriesProfit.append({'name': 'Own Profit', 'data': profit_round})
        seriesProfit.append({'name': 'Total Profit', 'data': totalProfit_round})
        Profitseries = safe_json(seriesProfit)

        return {'data': data, 'Catchseries': Catchseries, 'Profitseries': Profitseries,'others_data':others_data,
                'nation': oData[0], 'catch': oData[1], 'profit': oData[2], 'testunrange':self.group.b_unrange,
                'TotalIndProfit': totalIndProfit}

##-------------------------------
class ScientificAdvice(Page):

    def is_displayed(self):
        return self.group.b_round > 0

    timeout_seconds = 30

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):

        ##create area range series for uncertainty on biomass plot

        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label='rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label='rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim ="red"
            colorBlim_label='gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label='rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim ="rgba(68, 170, 213, 0)"
            colorBlim_label='rgba(68, 170, 213, 0)'
            colorBlim_range= 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        ## projection uncertainty
        j = -1
        UNarea=[]
        seq = list(range(len(self.group.b_proj)+1))

        # simplify nested list
        #dim_list = self.group.number_of_lists(self.group.b_unrange)

        # ! ici solution provisoire
        for i in range (1, 4):
            unArea = sum(self.group.b_unrange,[])

        for row in unArea[self.subsession.round_number - 1]:
            j=j+1
            UNarea.append([[seq[j]] + row])
        UNarea = sum(UNarea,[])

        ## Filling the data for graph
        ## Biomass estimation + projection under statu quo (same harvest level)

        data = {'Biomass': self.group.b_round,
                'Bmsy': Constants.Bmsy,
                'Blim':Constants.Blim,
                'Projection': self.group.b_proj,
                'UnRange': UNarea,
                'Blim_min':self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years' : Constants.xp_years,
                'colorBlim':colorBlim,
                'colorBlim_range':colorBlim_range,
                'colorBlim_range_label':colorBlim_range_label,
                'colorBlim_label':colorBlim_label}

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesProjection'] = list()
        data['seriesUnRange'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        data['seriesProjection'].append({'name': 'Projection',
                                         'data': self.group.b_proj})
        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass', 'data': biomass})

        data['seriesUnRange'].append({'name': 'UnRange',
                                      'data': UNarea})
        data['seriesBlim_min'].append({'name': 'Blim_min',
                                      'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesProjection'] = safe_json(data['seriesProjection'])
        data['seriesUnRange'] = safe_json(data['seriesUnRange'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return data

    ##-------------------------------

class End(Page):

    timeout_seconds = 30

    def vars_for_template(self):
        if self.group.b_round <= 0:
            message=' You have driven the stock to the collapse!! ' \
                    '.... Sorry you have to continue and to select an harvest of 0 UVS until the last period.... '
        else:
            message='_'
        data={'message':message}

        return (data)

    def is_displayed(self):
        return self.subsession.round_number == Constants.num_rounds or self.group.b_round <= 0

##-------------------------------
##page sequence
page_sequence = [
    #Introduction,
    #Form,
    Form_WaitPage,
    Catch_Pledge,
    Pledge_WaitPage,
    Pledge_Results,
    Catch_Choice,
    CatchChoice_WaitPage,
    Catch_Results,
    ScientificAdvice,
    End
]
