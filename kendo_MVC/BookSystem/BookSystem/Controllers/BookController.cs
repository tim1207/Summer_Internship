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

        /// <summary>
        /// 取類別
        /// </summary>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult GetBookClassListData()
        {
            return this.Json(this.codeService.GetSelectList("ClassName"));
        }

        /// <summary>
        /// 取使用者
        /// </summary>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult GetBookKeeperListData()
        {
            return this.Json(this.codeService.GetSelectList("Keeper",true));
        }

        /// <summary>
        /// 取狀態
        /// </summary>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult GetBookStatusListData()
        {
            return this.Json(this.codeService.GetSelectList("Status"));
        }

        /// 查詢資料
        [HttpPost()]
        public JsonResult GetSearchResult(Models.BookSearchArg book)
        {
            return Json(bookService.GetBookByCondtioin(book));
        }

        /// <summary>
        /// 刪除圖書
        /// </summary>
        /// <param name="BookID"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult DeleteBook(int bookID)
        {
            try
            {
                var num = bookService.DeleteBookById(bookID);
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

            return Json(bookService.GetBookLendRecordByBookID(bookId));
        }


        /// <summary>
        /// Get Detail
        /// </summary>
        /// <param name="bookId"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult BookDetailByID(int bookId)
        {
            return Json(bookService.GetBookByID(bookId));
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

        /// <summary>
        /// 取書名
        /// </summary>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult GetAllBook()
        {
            return Json(bookService.AllBookName());
        }
    }
}