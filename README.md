# ReductionsinOut-of-PocketPrices
Replication files and simulations for Johansson et al 2023 JHE


- Current version: `1.0.0 3feb2023`
- Jump to: [`overview`](#overview) [`example`](#example) [`replication codes`](#replication-codes)  [`data access`](#data-access)  [`update history`](#update-history) [`authors`](#authors) [`references`](#references)

-----------

## Overview 

This repository contains replication files and data for [Johansson, de New, Kunz, Petrie and Svensson (2023)](https://www.sciencedirect.com/science/article/pii/S0167629622001242); more details can be found in the paper. 

The analysis is based on external restricted datasets that we do not re-post here since they are held by different entities. 

Here we describe how to access them and provide our codes. We are encouraging any replication attempt and interested readers shall not hesitate to contact [Naimi Johansson](mailto:naimi.johansson@regionorebrolan.se) about any of these. For brevity, we also exclude the multitude of replication files for the Appendix version but are happy to provide these upon request. 

We first explain our kinked Donut Regression Discontinuity design approach using a simple simulation exercise and then briefly discuss how the results can be replicated (following an application to the data custodians)



## Example

#### County-wide supply differences 

The figure shows the application of the weighting for North Carolina. 

NC has access to nine HRRs (Asheville, Charlotte, Durham, Greensboro, Greenville, Hickory, Raleigh, Wilmington, and Winston-Salem); thus each county might have ties to several hospital referral regions. In the left Figure, we show the raw weighting, and in the right conditional on county-level characteristics (residualized) from our application. 

<img src="./_example/exampleNC.png" height="300">

#### Country-wide quality differences 

Across the whole country, the quality looks like this: 

<img src="./_example/e1_fig_map.png" height="400">

Of course, any other HRR-level characteristic can be disaggregated in the same manner. 

#### Some STATA example 

Here is the Stata script (see also example folder):

```stata
* change path 
cd "˜/Hospitalcompare/_raw/"

* 1. Load any type of HRR data, ie. Dartmouth provides a host of measures (in our application we use individual hospital quality aggregated to the HRR-level)
* Here for a simple example we just count the number of beds in HRR from AHA (see _sourcefiles for the source of data)
use Dartmouth_HOSPITALRESEARCHDATA/hosp16_atlas.dta
collapse (sum) AHAbeds , by(hrr)

* 2. Adjust format and merge with crosswalk 
tostring hrr, gen(hrrnum)
merge 1:m hrrnum using ˜/crosswalk/crosswalk_county_hrr.dta, nogen

* 3. Collapse on county-level for further analysis, using our preferred weights, others are provided
collapse (mean) AHAbeds [aw=zip_count_weight_in_HRR] , by(countyfips)
```

## Replication do-files 

Here we collect all do-files and data used in our analysis. We do not repost the full dataset as these were too large for the Github repository, please contact us if you have issues replicating it. 

## Data access

Has to be applied via ... 

## Update History
* **February 3, 2023**
  - initial commit
  

## Authors:

[Naimi Johansson](https://sites.google.com/view/naimijohansson/)
<br>Örebro University 

[Sonja De New](https://sites.google.com/site/sonjakassenboehmer/)
<br>Monash University

[Dennis Petrie](https://research.monash.edu/en/persons/dennis-petrie)
<br>Monash University

[Johannes S Kunz](https://sites.google.com/site/johannesskunz/)
<br>Monash University

[Mikael Sevensson](https://sites.google.com/view/mikael-svensson/)
<br>University of Florida

## References: 

Naimi Johansson, Sonja C. De New, Johannes S. Kunz, Dennis Petrie, & Mikael Svensson. 2023. [Reductions in Out-of-Pocket Prices and Forward-Looking Moral Hazard in Health Care.](https://www.sciencedirect.com/science/article/pii/S0167629622001242) Journal of Health Economics. 102710.





