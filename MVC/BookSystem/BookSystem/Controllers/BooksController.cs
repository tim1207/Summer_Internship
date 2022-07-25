using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace BookSystem.Controllers
{
    public class BooksController : Controller
    {
        readonly Models.CodeService codeService = new Models.CodeService();
        readonly Models.BookService bookService = new Models.BookService();

        /// <summary>
        /// Index page
        /// </summary>
        /// <returns></returns>
        public ActionResult Index()
        {
            // Data rename
            ViewBag.BookStatus = this.codeService.GetBookStatus();
            ViewBag.BookKeeper = this.codeService.GetBookKeeper();
            ViewBag.BookClassNameData = this.codeService.GetBookClassName();
            return View();
        }

        /// <summary>
        ///  Search page
        /// </summary>
        /// <param name="arg"></param>
        /// <returns></returns>
        [HttpPost()]
        public ActionResult Index(Models.BookSearchArg arg)
        {
            ViewBag.BookStatus = this.codeService.GetBookStatus();            
            ViewBag.BookKeeper = this.codeService.GetBookKeeper();
            ViewBag.BookClassNameData = this.codeService.GetBookClassName();
            ViewBag.SearchResult = bookService.GetBookByCondtioin(arg);
            return View("Index");
        }

        

        /// <summary>
        /// 新增 Book 畫面
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public ActionResult InsertBook()
        {
            ViewBag.BookClassNameData = this.codeService.GetBookClassName();
            return View("InsertBook");
        }


        /// <summary>
        /// Insert Book
        /// </summary>
        /// <param name="books"></param>
        /// <returns></returns>
        [HttpPost()]
        public ActionResult InsertBook(Models.Books books)
        {
            ViewBag.BookClassNameData = this.codeService.GetBookClassName();
            int BookID = this.bookService.InsertBook(books);
            // Model 
            if (BookID != 0)
            {
                ViewBag.Message = "success";
            }
            else
            {
                //inpossible
                // try catch
                ViewBag.Message = "fail";
            }

            return View(books);

        }



        /// <summary>
        /// Update Book page
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public ActionResult UpdateBook(int value)
        {

            Models.Books books = bookService.GetBookByID(value);
            ViewBag.BookClass = this.codeService.GetBookClassName();
            ViewBag.BookKeeper = this.codeService.GetBookKeeper(true);
            ViewBag.BookStatus = this.codeService.GetBookStatus();
            ViewBag.BookID = books.BookID;
            if(books.BookID == 0)
            {
                return View("Error");
            }
            return View(books);


        }

        /// <summary>
        /// Update Book
        /// </summary>
        /// <param name="bookData"></param>
        /// <returns></returns>
        [HttpPost()]
        public ActionResult UpdateBook(Models.Books bookData)
        {

            int result = bookService.UpdateBookInfor(bookData);
            if (result != 0)
            {
                ViewBag.Message = "success";
            }
            else
            {
                ViewBag.Message = "fail";
            }
   
            ViewBag.BookClass = this.codeService.GetBookClassName();
            ViewBag.BookKeeper = this.codeService.GetBookKeeper(true);
            ViewBag.BookStatus = this.codeService.GetBookStatus();
            return View();
        }



        /// <summary>
        /// 
        /// </summary>
        /// <param name="BookId"></param>
        /// <returns></returns>
        [HttpGet]
        public ActionResult LendRecord(int value)
        {

            ViewBag.LendResult = bookService.GetBookLendRecordByBookID(value);
            ViewBag.BookKeeper = this.codeService.GetBookKeeper(true);
            Models.Books books = bookService.GetBookByID(value);
            if (books.BookID == 0)
            {
                return View("Error");
            }
            return View("LendRecord");

        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public ActionResult BookDetial(int value)
        {
            Models.Books books = bookService.GetBookByID(value);
            ViewBag.BookClass = this.codeService.GetBookClassName();
            ViewBag.BookKeeper = this.codeService.GetBookKeeper(true);
            ViewBag.BookStatus = this.codeService.GetBookStatus();
            if (books.BookID == 0)
            {
                return View("Error");
            }
            return View(books);
        }

        /// <summary>
        /// delete book
        /// </summary>
        /// <param name="bookID"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult DeleteBook(string bookID)
        {// TODO:
            try
            {
                var isSuccess = bookService.DeleteBookById(bookID);
                if (isSuccess > 0)
                {
                    return this.Json(true);
                }
                else
                {
                    return this.Json(false);
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}