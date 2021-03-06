source("../src/anomaly-model.R")

#' Class representing Isolation Forest model
#' 
#' @description
#' Concrete class of abstract base class Model for iForest anomaly detector.

ModelIsoForest = R6::R6Class("ModelIsoForest",
  inherit = Model,
  public = 
    list(

         #' Isolation forest model constructor
         #' 
         #' @description
         #' function creates iForest model as a partial function with given `params` list.
         #' @param params named list of params

         initialize = function(params = NULL) {
          super$initialize("iForest")
          self$param_set$ntrees = controlParam(params, "ntrees", 500)
          self$param_set$ntry = controlParam(params, "ntry", 3)
          self$param_set$prob_pick_avg_gain = controlParam(params, "prob_pick_avg_gain", 0)
          self$param_set$prob_pick_pooled_gain = controlParam(params, "prob_pick_pooled_gain", 0)
          self$param_set$prob_split_avg_gain = controlParam(params, "prob_split_avg_gain", 0)
          self$param_set$prob_split_pooled_gain = controlParam(params, "prob_split_pooled_gain", 0)
          self$param_set$min_gain = controlParam(params, "min_gain", 0)
          self$param_set$categ_split_type = controlParam(params, "categ_split_type", "subset")
          self$param_set$all_perm = controlParam(params, "all_perm", FALSE)
          self$param_set$weights_as_sample_prob = controlParam(params, "weights_as_sample_prob", TRUE)
          self$param_set$sample_with_replacement = controlParam(params, "sample_with_replacement", FALSE)
          self$param_set$penalize_range = controlParam(params, "penalize_range", TRUE)
          self$param_set$weigh_by_kurtosis = controlParam(params, "weigh_by_kurtosis", FALSE)
          self$param_set$coefs = controlParam(params, "coefs", "normal")
          self$param_set$assume_full_distr = controlParam(params, "assume_full_distr", TRUE)
          self$param_set$build_imputer = controlParam(params, "build_imputer", FALSE)
          self$param_set$output_imputations = controlParam(params, "output_imputations", FALSE)
          self$param_set$min_imp_obs = controlParam(params, "min_imp_obs", 3)
          self$param_set$depth_imp = controlParam(params, "depth_imp", "higher")
          self$param_set$weigh_imp_rows = controlParam(params, "weigh_imp_rows", "inverse")
          self$param_set$output_score = controlParam(params, "output_score", FALSE)
          self$param_set$output_dist = controlParam(params, "output_dist", FALSE)
          self$param_set$square_dist = controlParam(params, "square_dist", FALSE)
          self$param_set$random_seed = controlParam(params, "random_seed", 1)

          self$model_struct = 
             purrr::partial(
              isotree::isolation.forest, 
              sample_weights = self$param_set$sample_weights,
              ntrees = self$param_set$ntrees, 
              ntry = self$param_set$ntry,
              prob_pick_avg_gain = self$param_set$prob_pick_avg_gain, 
              prob_pick_avg_gain = self$param_set$prob_pick_pooled_gain, 
              prob_split_avg_gain = self$param_set$prob_split_avg_gain, 
              prob_split_pooled_gain = self$param_set$prob_split_pooled_gain,
              min_gain = self$param_set$min_gain, 
              categ_split_type = self$param_set$categ_split_type,
              all_perm = self$param_set$all_perm, 
              weights_as_sample_prob = self$param_set$weights_as_sample_prob,
              sample_with_replacement = self$param_set$sample_with_replacement, 
              penalize_range = self$param_set$penalize_range, 
              weigh_by_kurtosis = self$param_set$weigh_by_kurtosis, 
              coefs = self$param_set$coefs, 
              assume_full_distr = self$param_set$assume_full_distr,
              build_imputer = self$param_set$build_imputer,
              output_imputations = self$param_set$output_imputations,
              min_imp_obs = self$param_set$min_imp_obs,
              depth_imp = self$param_set$depth_imp,
              weigh_imp_rows = self$param_set$weigh_imp_rows,
              output_score = self$param_set$output_score, 
              output_dist = self$param_set$output_dist,
              square_dist = self$param_set$square_dist,
              random_seed = self$param_set$random_seed
              )
         },

         #' Construct isolation forest
         #'
         #' @description
         #' function creates isolation forest on given data set.
         #' @param data data frame
         #' @param sample_size internal param of iForest
         #' @param max_depth internal param of iForest

         train = function(data, sample_size = NULL, max_depth = NULL) {
           self$model_state =
             self$model_struct(
                   df = data,
                   sample_size = ifelse(is.null(sample_size), nrow(data), sample_size),
                   max_depth = ifelse(is.null(max_depth), ceiling(log2(nrow(data))), max_depth),
                   missing_action = ifelse(min(3, ncol(data)) > 1, "impute", "divide"),
                   new_categ_action = ifelse(min(3, ncol(data)) > 1, "impute", "weighted")
                 )

          },
          
         #' Predict values
         #'
         #' @description
         #' function assign anomaly scores for given data frame
         #' and save result of prediction to `predict_state` field.
         #' @param data data frame

         predict = function(data) {
          self$predict_state = 
            predict(self$model_state, data)
         },
         
         #' Print model
         #' 
         #' @description
         #' function prints model to standard output

         print = function() {
           super$print()
         }
     )
)

