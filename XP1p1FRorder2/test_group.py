from unittest import TestCase
import random
import math
import numpy
from numpy import arange

class TestGroup(TestCase):

## growth function
    def growth(self, b):
        biomass = round(b + (0.8 * b) * (1 - (b / 30)), 0)
        return biomass  # []

##test log growth when stock = 0
    #def test_growth(self,b=0):
     #  g= math.log(self.growth(b))
     #  self.assertTrue(numpy.isinf(g))


## test compute payoff functions
    def test_compute_payoff(self, stock=2, harvest=1, harvestInd=0, session="T2",round_number=5):

        if (harvest + harvestInd) == 0:
            prop = 0
        else:
            prop = harvestInd / (harvest + harvestInd)

        if stock - (harvest + harvestInd) <= 0:
            prof = -5
        else:
            if session == 'T1':
                if round_number == 1:
                    prof = round((1 * harvestInd) -
                                 (13 * (math.log(self.growth(b=30)) -
                                                    math.log(self.growth(b=30) - (
                                                    harvest + harvestInd))) * (prop)), 1)
                else:
                    prof = round((1 * harvestInd) -
                                 (13 * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)),
                                 1)
            else:
                if round_number == 1:
                    prof = round((1 * harvestInd) -
                                 (13 * (math.log(self.growth(b=30)) -
                                                    math.log(self.growth(b=30) - (
                                                    harvest + harvestInd))) * (prop)), 1)
                else:
                    if stock <= 10:
                        prof = round((1 * harvestInd) - 5 -
                                     (13 * (math.log(self.growth(b=stock)) -
                                                        math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)
                    if stock > 10:
                        prof = round((1 * harvestInd) -
                                     (13 * (math.log(self.growth(b=stock)) -
                                                        math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)

        self.assertTrue(prof is not None)


