
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Food Demand Forecasting

<!-- badges: start -->
<!-- badges: end -->

## Project Intro:

The goal of this project is to provide forecast values for the number of
orders for meal/center combos to a food delivery service. We have a
total of **3548** meal/center combos (i.e. 77 centers & 51 meals),
meaning that 3548 time series models will have to be fitted. This
technique in business environment is also known as **Scalable
Forecasting**. The project details & materials are available on the
following link
<https://datahack.analyticsvidhya.com/contest/genpact-machine-learning-hackathon-1/>.

In this github repo the methodology, R scripts, submission files, time
series models & machine learning models used to tackle this problem can
be found.

**PS: This is not the ONLY method to tackle this problem. However, this
is one way to tackle this problem.**

The following time series models were used to forecast the number of
orders: **Naive, Seasonal Naive, Drift, Simple Exponential Smoothing
(SES), Holt’s Linear, Additive Damped Trend, STL Decomposition with ETS,
ARIMA, Dynamic Harmonic Regression, Time Series Linear Regression,
CROSTON, SBA, Neural Network & Ensemble Model**. These were not the only
models used to forecast; there are plenty of other models that can be
used for this problem. However, the computational time to train the
models must be considered.

The software used for this work was **R** and the following **R
packages** were used to forecast:  
**fpp3 :** This package contains several time series model functions and
other time series related functions. This package includes **tsibble,
tsibbbledata, fable** and **feasts** packages.  
**tsintermittent :** This package is used to find demand patterns and
also contains intermittent time series related function.  
**tidyverse :** This package is used for data wrangling with pipe
operators (tidy work flow).

# Step 01: Data Preperation & Finding Demand Patterns.

In this stage, data wrangling steps were performed. This data was then
transformed to time series data (i.e. to **tsibble** object: this is a
special type of data that handles time series models). The following
shows the data wrangling steps:

The first few weeks of transactions for Center \#24 (which can be seen
in the plot below) were removed as there were no transactions available
for several weeks after these first few weeks. However, there were
continuous transactions after this time period, hence these were used to
fit the model.  
The following plot shows aggregated number of orders for Center \#24:
![](README_files/figure-gfm/center24-1.png)<!-- -->

A complete meal/center combos time series data was made i.e. meaning
that some meal/center combos had some missing weeks; new entries were
created for those missing entries by replacing the number of orders with
**0** and filled with **previous values** for other variables
(emailer\_for\_promotion, homepage\_featured, base\_price,
checkout\_price). For example, the following time series data shows that
after the 4th week there is data missing up to 7th week. Table 2 shows
the completed data with the new entries for those missing weeks
(i.e. weeks 5 & 6).

<p align="center">
<img src="README_files/figure-gfm/table_1.png" width="1200px">
</p>
<p align="center">
<img src="README_files/figure-gfm/table_2.png" width="1200px">
</p>

Some Meal/Center combos showed less transactions i.e. fewer than 20
transactions. These combos were separated and forecast models were
fitted specifically for them using **Cross Validation (CV)** method.

Finally, the following demand patterns for each meal/center combo, based
on the number of orders, were identified: **Smooth, Erratic, Lumpy &
Intermittent**. The method used here to identify demand patterns was
**Syntetos, Boylan and Croston (2004) (SBC).** Identifying these demand
patterns meant that different times series models can be applied to them
specifically. For example, **Croston & SBA** were suitable for
intermittent demand patterns. Hence, this helped to increase the
accuracy of forecasting. R script for **Step 01** can be found in
`00-GT-Data Prep & Discovery.R` & **demand pattern table** can be found
in following path: `data\processed\ts_categorization.csv`.

##### Smooth:

The smooth demand pattern shows a regular demand and regular time.
i.e. This type of products can be sold every day or every week.

##### Erratic:

The erratic demand pattern shows regularity in time but the selling
quantity varied dramatically. i.e. This type of products can be sold
everyday or every week however, for example, one day it may sell 3 in
quantity whereas, another day it could sell 100 in quantity.

##### Intermittent:

The intermittent demand pattern shows irregularity in time and
regularity in quantity pattern. i.e. This type of product is sold for
the first week then for several weeks would not be sold but at the end,
the same amount of product is sold.

##### Lumpy:

The lumpy demand pattern shows irregularity in time and irregularity in
the quantity pattern. This particular type of demand pattern was
difficult to forecast no matter what type of time series models was
used. A solution for this type of product is to have a safety stock.

The plots below show what each demand pattern looks like:
![](README_files/figure-gfm/ts%20categorization-1.png)<!-- -->

![](README_files/figure-gfm/ts%20stack%20graph-1.png)<!-- -->

The above plot showed that in the data, a majority of time series combos
fell under Smooth & Erratic. This meant that a regular time series model
such as ARIMA, ETS etc. would have suited well. However, advanced models
such as **Croston & SBA** were fitted in order to tackle the
intermittent & lumpy demand pattern. The Cross Validation method had
been used to fit **No Demand** (i.e. transactions less than 20) combos.

# Step 02: Find suitable models for Smooth & Erratic Patterns.

In this stage, time series models for Smooth & Erratic demand patterns
were fitted i.e. First, the data was split into train & test (last 10
weeks) data for each meal/center combo. The following time series models
were then fitted for each train data of meal/center combo. Here, number
of orders (Y) was log transformed to impose a positive constraint by
adding unit 1 to overcome **log(0)** infinity issue.

##### 1. Naive

The Naive model sets all future values the same as the last observation
value.

![](README_files/figure-gfm/naive-1.png)<!-- -->

##### 2. Seasonal Naive

The seasonal naive model was used for seasonal data. In this situation,
each future value is equal to the last value from the same season.

![](README_files/figure-gfm/snaive-1.png)<!-- -->

##### 3. Drift

The drift model is a variation of Naive model, allowing forecast to
increase or decrease over time.

![](README_files/figure-gfm/drift-1.png)<!-- -->

##### 4. Simple Exponential Smooth

The simple exponential smooth model was used when a clear trend or
seasonal pattern was not identified.

![](README_files/figure-gfm/ses-1.png)<!-- -->

##### 5. Holt’s Linear

The Holt’s Linear model is an extended version of SES allowing to
forecast with trend.

![](README_files/figure-gfm/hl-1.png)<!-- -->

##### 6. Damped Additive Trend

The Damped Additive Trend model is an extended version of Holt’s Linear,
allowing trend to change over time with a damped parameter **phi**.

![](README_files/figure-gfm/hld-1.png)<!-- -->

<!-- ##### 4. State Space Models -->
<!-- The state space models contained 18 models with a combination of Error (Additive, Multiplicative), Trend (None, Additive, Damped) & Seasonal (None, Additive, Multiplicative). ETS function from fpp3 R package was used to fit the ETS models which automatically fitted those 18 models and selected the best model using __min AICC__. The explanation and theory of State Space Models can be found on the following link <https://otexts.com/fpp3/ets.html>. -->

##### 7. Forecasting with Decomposition

The decomposition model was used to decompose the time series using
**Seasonal and Trend decomposition using Loess (STL)** method. ETS
method was then used to forecast the **seasonally adjusted** data, after
which the seasonal component was added to the forecast data.

![](README_files/figure-gfm/decomp-1.png)<!-- -->

##### 8. ARIMA

The ARIMA models explain the autocorrelations in the data. ARIMA
function was used from fpp3 R package to fit the ARIMA models, which
automatically selected the ARMA orders using **min AICC**. The
explanation and theory of ARIMA Models can be found on the following
link: <https://otexts.com/fpp3/arima.html>.

![](README_files/figure-gfm/arima-1.png)<!-- -->

##### 9. Dynamic Harmonic Regression

The Dynamic Harmonic Regression model allows the inclusion of other
data, such as base price, checkout price, email promotion & homepage
featured. The explanation and theory of Dynamic Harmonic Regression
Models can be found on the following link:
<https://otexts.com/fpp3/dynamic.html>.

![](README_files/figure-gfm/dhr-1.png)<!-- -->

##### 10. Time Series Regression

The time series regression model is used to forecast the dependent
variable Y assuming that it has a linear relationship with other
independent variables X. i.e. in this situation, an assumption was made
when forecasting that the number of orders and checkout price, base
price, emailer for promotion & homepage featured had a linear
relationship.

![](README_files/figure-gfm/tslm-1.png)<!-- -->

##### 11. Ensemble

The ensemble model simply uses several different models at the same time
and calculates average value of the resulting forecasts. For example,
here, ARIMA, SES & Decomposition models were used together to calculate
the average forecast value.

![](README_files/figure-gfm/sm%20ensemble-1.png)<!-- -->

R script for **Step 02** can be found on
`01-GT-forecast_model-smooth.R`. The forecast values from fitted models
can be found in the following path:
`data\processed\smooth_forecast_tbl.csv`

# Step 03: Find suitable models for Intermittent & Lumpy Patterns.

In this stage, time series models for Intermittent & Lumpy demand
patterns were fitted i.e. Firstly, the data was split into train & test
(last 10 weeks) data for each meal/center combo. The following time
series models ( **CROSTON, SBA, SES, ARIMA & Ensemble** ) were then
fitted.

##### 1. CROSTON

The Croston model is the most suitable method for slow moving products
(intermittent). The theory behind this method can be found on the
following link:
<https://cran.r-project.org/web/packages/tsintermittent/index.html>.

![](README_files/figure-gfm/crost-1.png)<!-- -->

##### 2. SBA

The SBA model is another variant / improved version of Croston method.
Theory and research papers for this method can be found on the following
link:
<https://cran.r-project.org/web/packages/tsintermittent/index.html>.

![](README_files/figure-gfm/sba-1.png)<!-- -->

##### 3. Ensemble for Intermittent

Here, CROSTON, SBA, ARIMA & SES models were used together to calculate
the average forecast value.

![](README_files/figure-gfm/int%20ensemble-1.png)<!-- -->

<!-- ##### 3. Neural Networks -->
<!-- The neural networks model shows a nonlinear relationship between Y variable and X variables. Theory for this method can be found on this link: <https://otexts.com/fpp3/nnetar.html>. -->
<!-- ```{r nn, echo=FALSE, fig.dim=c(8,3)} -->
<!-- forecast_tbl %>% -->
<!--   filter(center_id == 55, meal_id == 2640, .model == "neural_mod") %>% -->
<!--   mutate(week = 136:145) %>% -->
<!--   rename(num_orders = fc_qty) %>% -->
<!--   bind_rows(meal_demand_tbl %>% filter(center_id == 55, meal_id == 2640)) %>% -->
<!--   mutate(.model = ifelse(is.na(.model), "Actual", "NNETAR")) %>% -->
<!--   ggplot(aes(week, num_orders)) + -->
<!--   geom_line(aes(color = .model), size = 0.8) + -->
<!--   scale_color_manual(values = c("#FDE725FF", "#440154FF")) + -->
<!--   labs(x = "Week", y = "# of Orders", title = "NNETAR Model") + -->
<!--   theme(legend.title = element_blank(), -->
<!--         legend.position = "bottom") -->
<!-- ``` -->

R script for **Step 03** can be found in
`02-GT-intermittent forecast.R`. The forecast values from fitted models
can be found in `data\processed\inter_forecast_tbl.csv`.

# Step 04: Find Suitable Forecast Models.

In this stage, suitable models for each meal/center combo were then
found within the fitted models. i.e. The accuracy for each
**meal/center/model** combo (i.e. **3548x7 time series models** ) was
calculated in order to select a suitable model for each **meal/center**
combo. The accuracy metrics used here was **RMSLE**. RMSLE was used as
it was the metrics used for this competition. However, personally
**RMSSE** was preferred as this was used in the **M5 forecasting
competition.** The following plots show the accuracy (RMSLE) density
plot, giving an overview of how many meal/center combos achieved high or
low accuracy:

![](README_files/figure-gfm/smooth%20accuracy%20density%20plots-1.png)<!-- -->

The above plot shows that high accuracy (i.e. less than 1 RMSLE) was
achieved for a majority of meal/center combos. However, there were a few
meal/center combos which revealed low accuracy; for these low accuracy
combos, other advanced time series/machine learning models could be
fitted to increase the forecast accuracy. Furthermore, the majority of
combos with low accuracy were Lumpy/Intermittent which meant that for
these type of combos, rather than fitting advance models, the focus
should be on safety stock calculations.

The following plot shows the number of meal/center combos against the
models, chosen by minimum RMSLE.
![](README_files/figure-gfm/smooth%20number%20of%20models-1.png)<!-- -->

The above plot shows that ARIMA, Dynamic Harmonic Regression & Time
Series Regression models are the most fitted models for meal/center
combos. R script for **Step 04** can be found in
`03-Accuracy calculation.R`. Suitable model lists selected using minimum
RMSLE can be found in the following path:
`data\processed\suitable_model_tbl.csv`.

# Step 05: Final Step.

In this stage, forecast for each meal/center combo was performed with
the new data provided by the hackathon competition
(`data\raw\test\test_QoiMO9B.csv`). The time series models used here can
be found in **Step 04** (`data\processed\suitable_model_tbl.csv`). The
forecast final output submission file can be found in
`output\GT_Submission_date`. The following plot shows how the forecast
values look in the train/test split stage and how they will look in the
future by using the most suitable model. For example, the plot below
shows how the forecast values look in the test period (Week 136 - 145)
and then in the future period (146 - 155) in Center 10 and Meal 1885 ,
using the most suitable model **Decomposition Model**.

![](README_files/figure-gfm/final%20plot-1.png)<!-- -->

R script for **Step 05** can be found in `05-GT-Pipeline.R`.  
Forecast - related useful links:  
<https://otexts.com/fpp3/> : The forecasting book.  
<https://kourentzes.com/forecasting/2014/06/23/intermittent-demand-forecasting-package-for-r/>
: Intermittent forecasting related theory.  
<https://frepple.com/blog/demand-classification/> : Demand patterns
explanations.  
<https://cran.r-project.org/web/packages/tsintermittent/index.html> :
Intermittent forecasting related theory.
