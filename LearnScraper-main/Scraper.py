# remember to run 'python setup.py' before the first time

import helpers


helpers.setup_driver()
helpers.loginLearn()
# in folders: HEIN110372023-4,
# unknown: HEIN110472023-4,HEIN110482022-3,HEIN110662023-4,HEIN110592023-4,HEIN110622022-3,HEIN110622023-4,HEIN110632023-4,HEIN110682023-4,HEIN110762023-4,HEIN110432023-4,zp_FTDL_playground,PUHR111032023
# helpers.scrapeCourseDataset(['HEIN110622023-4'], helpers.Datasets.Diaries)

# helpers.scrapeCourseDatasetFromUrls(['https://www.learn.ed.ac.uk/ultra/courses/_115955_1/engagement/discussion/_9935062_1?view=discussions&courseId=_115955_1', 
#                                      'https://www.learn.ed.ac.uk/ultra/courses/_115955_1/engagement/discussion/_9935063_1?view=discussions&courseId=_115955_1'], 
#                                      'HEIN110622023-4')


# HEIN110482022-3	Introduction to databases and information systems (2022-2023)[FLEX]
course_id = "HEIN110482022-3"
discussion_board_data = [
                        "https://www.learn.ed.ac.uk/ultra/courses/_105453_1/engagement/discussion/_8374738_1?view=discussions&courseId=_105453_1", 
                         "https://www.learn.ed.ac.uk/ultra/courses/_105453_1/engagement/discussion/_8374754_1?view=discussions&courseId=_105453_1", 
                         "https://www.learn.ed.ac.uk/ultra/courses/_105453_1/engagement/discussion/_8410310_1?view=discussions&courseId=_105453_1", 
                         "https://www.learn.ed.ac.uk/ultra/courses/_105453_1/engagement/discussion/_8410312_1?view=discussions&courseId=_105453_1",
                           "https://www.learn.ed.ac.uk/ultra/courses/_105453_1/engagement/discussion/_8410314_1?view=discussions&courseId=_105453_1"]





# # HEIN110372023-4SV1FLEX	Introduction to data science in health and social care (2023-2024)[FLEX]
# course_id = "HEIN110372023-4SV1FLEX"
# discussion_board_data = [
#                                     "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9328870_1?view=discussions&courseId=_110986_1", 
#                                     "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9328877_1?view=discussions&courseId=_110986_1",
#                                       "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9328880_1?view=discussions&courseId=_110986_1", 
#                                       "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9328884_1?view=discussions&courseId=_110986_1",
#                                      "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9328887_1?view=discussions&courseId=_110986_1",
#                                        "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9329172_1?view=discussions&courseId=_110986_1", 
#                                        "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9329224_1?view=discussions&courseId=_110986_1", 
#                                        "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9329227_1?view=discussions&courseId=_110986_1", 
#                                        "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9329299_1?view=discussions&courseId=_110986_1", 
#                                        "https://www.learn.ed.ac.uk/ultra/courses/_110986_1/engagement/discussion/_9329303_1?view=discussions&courseId=_110986_1"
#                                        ]



helpers.scrapeCourseDiscussionsDirectlyFromUrls(course_id,discussion_board_data)



