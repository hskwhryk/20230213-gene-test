## ==================================================================================== ##
# START Shiny App for analysis and visualization of transcriptome data.
# Copyright (C) 2016  Jessica Minnier
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# You may contact the author of this code, Jessica Minnier, at <minnier@ohsu.edu>
## ==================================================================================== ##
## 

## ==================================================================================== ##
## This tab is used to input the count or normalized data files
## ==================================================================================== ##

tabPanel("Input Data", 
         ## ==================================================================================== ##
         ## Left hand column has the input data settings and options
         ## ==================================================================================== ##
         fluidRow(column(4,wellPanel(
           # PDF of instructions link
           downloadLink("instructionspdf",label="Download Instructions (pdf)"),
           # Upload data from csv, upload data from RData, use example data
           radioButtons('data_file_type','Use example file or upload your own data',
                        c(#'Upload Data'="upload",
                          #'START RData file'="previousrdata",
                          'Example Data'="examplecounts"
                        ),selected = "examplecounts"),
           # Conditional panels appear based on input.data_file_type selection
           conditionalPanel(condition="input.data_file_type=='previousrdata'",
                            fileInput('rdatafile','Upload START Generated RData File'),
                            conditionalPanel("output.fileUploaded",
                                             h4(strong("Check data contents then click:")))
           ),
           conditionalPanel(condition="input.data_file_type=='upload'",
                            radioButtons("inputdat_type","Input Data Type:",
                                         c("Expression data: Gene Counts or log-expression (log2cpms)"="expression_only",
                                           "Analyzed data: Expression Values, p-values, fold changes"="analyzed")),
                            conditionalPanel(
                              condition="input.inputdat_type=='expression_only'",
                              downloadLink("example_counts_file",label="Download Example Count File"),
                              p(""),
                              img(src="examplecounts.png",width="100%"),
                              tags$ul(
                                tags$li("File must have a header row."), 
                                tags$li("First/Left-hand column(s) must be gene identifiers."), 
                                tags$li("Format expression column names as GROUPNAME_REPLICATE#: Group1_1, Group1_2, Group2_1, Group2_2...")
                              ),
                              radioButtons("analysis_method","Analysis Method",
                                           c("edgeR"="edgeR",
                                             "voom/limma"="voom",
                                             "Array or counts already normalized, linear models"="linear_model"))
                            ),
                            conditionalPanel(condition="input.inputdat_type=='analyzed'",
                                             downloadLink("example_analysis_file",label="Download Example Analysis Results File"),
                                             p(""),
                                             img(src="exampleanalysisdata.png",width="100%"),
                                             tags$ul(
                                               tags$li("File must have a header row."), 
                                               tags$li("Format expression column names as GROUPNAME_REPLICATE#: Group1_1, Group1_2, Group2_1, Group2_2..."),
                                               tags$li("Number & order of fold changes must MATCH p-value number & order.")
                                             )
                            ),
                            fileInput('datafile', 'Choose File Containing Data (.CSV)',
                                      accept=c('text/csv', 
                                               'text/comma-separated-values,text/plain', 
                                               '.csv')),
                            conditionalPanel(condition="input.inputdat_type=='analyzed'",
                                             #checkboxInput('header', 'Header', TRUE),
                                             selectInput("c_geneid1",label="First column # with gene IDs",choices=NULL),
                                             selectInput("c_geneid2",label="Last column # with gene IDs",choices=NULL),
                                             selectInput("c_expr1",label="First column # with expression values",choices=NULL),
                                             selectInput("c_expr2",label="Last column # with expression values",choices=NULL),
                                             selectInput("c_fc1",label="First column # with fold changes",choices=NULL),
                                             selectInput("c_fc2",label="Last column # with fold changes",choices=NULL),
                                             radioButtons("isfclogged",label="Is FC logged? (if false, expression values will be log2-transformed for visualization)",choices=c("Yes (Leave it alone)","No (Log my data please)"),selected="No (Log my data please)"),
                                             selectInput("c_pval1",label="First column # with p-values",choices=NULL),
                                             selectInput("c_pval2",label="Last column # with p-values",choices=NULL),
                                             selectInput("c_qval1",label="First column # with adjusted p-values (can be same columns as p-values)",choices=NULL),
                                             selectInput("c_qval2",label="Last column # with adjusted p-values (can be same columns as p-values)",choices=NULL)
                            )
           ),
           conditionalPanel("output.fileUploaded",
                            actionButton("upload_data","Submit Data",
                                         style="color: #fff; background-color: #CD0000; border-color: #9E0000"))
         )#,
         # add reference group selection
         # missing value character?
         ),#column
         ## ==================================================================================== ##
         ## Right hand column shows data input DT and data analysis result DT
         ## ==================================================================================== ##
         column(8,
                bsCollapse(id="input_collapse_panel",open="data_panel",multiple = FALSE,
                           bsCollapsePanel(title="Data Contents: Check Before `Submit`",
                                           value="data_panel",
                                           dataTableOutput('countdataDT')                       
                           ),
                           bsCollapsePanel(title="Analysis Results: Ready to View Other Tabs",
                                           value="analysis_panel",
                                           downloadButton('downloadResults_CSV','Save Results as CSV File'),
                                           downloadButton('downloadResults_RData',
                                                          'Save Results as START RData File for Future Upload',
                                                          class="mybuttonclass"),
                                           dataTableOutput('analysisoutput'),
                                           tags$head(tags$style(".mybuttonclass{background-color:#CD0000;} .mybuttonclass{color: #fff;} .mybuttonclass{border-color: #9E0000;}"))
                           )
                )#bscollapse
         )#column
         )#fluidrow
)#tabpanel
