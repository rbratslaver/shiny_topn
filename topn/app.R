pacman::p_load(tidyverse,shiny,shinydashboard,gt,skimr,janitor)


# roadmap -----------------------------------------------------------------

# #display table in dashboard body (see table code below)
# # update table based on user selection of:
# #group_by variables
# #aggregation type (i.e. mean,median,etc...)
# #aggregation metric (i.e. cty,hwy,displ,etc...)
# # "top_n" value (i.e. how many values to show before grouping into "others"; base case is 3)
# #table code
# mpg %>% 
#     group_by(manufacturer,model) %>% 
#     summarise(mean_cty = mean(cty),.groups='drop_last') %>% 
#     mutate(model = case_when(dense_rank(desc(mean_cty))<=3~model,TRUE~'others')) %>% 
#     mutate(index = case_when(
#         model=='others'~1,
#         TRUE~0
#     )) %>% 
#     ungroup() %>% 
#     group_by(manufacturer,model,index) %>% 
#     summarise(mean_cty = mean(mean_cty)) %>% 
#     arrange(manufacturer,index,desc(mean_cty)) %>%
#     select(-index) %>% 
#     ungroup() %>% 
#     gt() %>% 
#     fmt_number('mean_cty',decimals = 1)



# input vars -------------------------------------------------------------------

mpg %>% select(!where(is.numeric)) %>% names()->vars
c('mean','median')->agg
mpg %>% select(where(is.numeric)) %>% names()->metrics



# ui ----------------------------------------------------------------------

header <- dashboardHeader(title = 'Top N MPG Dashboard')


sidebar <- dashboardSidebar(
    selectInput('groupby_vars','select grouping variables',vars),
    selectInput('agg_type','select aggregation',agg),
    selectInput('metric','select metric',metrics),
    sliderInput('topn_value',
                "select desired topn",
                min=0,
                max=10,
                value=1))




body <- dashboardBody(
  fluidRow(
    box(tableOutput("topn_table"),width=4)
  )
)  


ui <- dashboardPage(header,sidebar,body)

  




# server ------------------------------------------------------------------


server <- function(input, output) {
  output$topn_table <- renderTable(
    mpg %>%
        group_by(manufacturer,model) %>%
        summarise(mean_cty = mean(cty),.groups='drop_last') %>%
        mutate(model = case_when(dense_rank(desc(mean_cty))<=1~model,TRUE~'others')) %>%
        mutate(index = case_when(
            model=='others'~1,
            TRUE~0
        )) %>%
        ungroup() %>%
        group_by(manufacturer,model,index) %>%
        summarise(mean_cty = mean(mean_cty)) %>%
        arrange(manufacturer,index,desc(mean_cty)) %>%
        select(-index) %>%
        ungroup() %>%
        gt() %>%
        fmt_number('mean_cty',decimals = 1)
  )
}


# run app -----------------------------------------------------------------


shinyApp(ui = ui, server = server)
