using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace BookSystem.Controllers
{
    public class BookController : Controller
    {
        Models.CodeService codeService = new Models.CodeService();
        Models.BookService bookService = new Models.BookService();

        /// <summary>
        /// GET: Books
        /// </summary>
        /// <returns></returns>

        public ActionResult Index()
        {
            return View();
        }
        // TODO: mix together
        public JsonResult GetBookClassListData()
        {
            return this.Json(this.codeService.GetSelectList("ClassName"));
        }

        public JsonResult GetBookKeeperListData()
        {
            return this.Json(this.codeService.GetSelectList("Keeper",true));
        }

        public JsonResult GetBookStatusListData()
        {
            return this.Json(this.codeService.GetSelectList("Status"));
        }

        /// 查詢資料
        [HttpPost()]
        public JsonResult GetSearchResult(Models.BookSearchArg book)
        {
            List<Models.Book> getBook = bookService.GetBookByCondtioin(book);
            return Json(getBook);
        }

        /// <summary>
        /// 刪除圖書
        /// </summary>
        /// <param name="BookID"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult DeleteBook(int BookID)
        {
            try
            {
                var num = bookService.DeleteBookById(BookID);
                if (num > 0)
                {
                    return this.Json(true);
                }
                else
                {
                    return this.Json(false);
                }
            }
            catch (Exception)
            {
                return this.Json(false);
            }

        }


        /// <summary>
        /// 借閱紀錄畫面
        /// </summary>
        /// <param name="BookID"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult BookLendRecord(int bookId)
        {

            var record = bookService.GetBookLendRecordByBookID(bookId);
            return Json(record);
        }


        /// <summary>
        /// Get Detail
        /// </summary>
        /// <param name="bookId"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult BookDetailByID(int bookId)
        {
            var detail = bookService.GetBookByID(bookId);
            return Json(detail);
        }

        /// <summary>
        /// Insert Book
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult InsertBook(Models.Book book)
        {
            try
            {
                int bookID = bookService.InsertBook(book);
                if (bookID > 0)
                {
                    return this.Json(true);
                }
                return this.Json(false);

            }
            catch (Exception)
            {
                return this.Json(false);
            }
        }

        /// <summary>
        /// Update Book
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult UpdateBook(Models.Book book)
        {
            try
            {
                int result = bookService.UpdateBookInfor(book);
                if (result > 0)
                {
                    return this.Json(true);
                }
                return this.Json(false);
            }
            catch (Exception)
            {
                return this.Json(false);
            }
        }

        [HttpPost()]
        public JsonResult GetAllBook()
        {
            return Json(bookService.AllBookName());
        }
    }
}