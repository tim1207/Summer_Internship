using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace BookSystem.Models
{

    public class BookService
    {
        /// <summary>
        /// 資料庫連線
        /// </summary>
        /// <returns></returns>
        private string GetDBConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString.ToString();
        }

        /// <summary>
        /// 新增書本
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        public int InsertBook(Models.Book book)
        {

            string sql = @"INSERT INTO BOOK_DATA(BOOK_NAME, BOOK_CLASS_ID, BOOK_AUTHOR, BOOK_BOUGHT_DATE, BOOK_PUBLISHER, BOOK_AMOUNT,BOOK_NOTE, 
                            BOOK_STATUS,CREATE_DATE, CREATE_USER, MODIFY_DATE, MODIFY_USER,BOOK_KEEPER)
						   VALUES(@BookName,@BookClassID,@BookAuthor,@BookBoughtDate,@BookPublisher,@BookAmount,@BookNote,@CanBeLend,getDate(),@Admin,getDate(),@Admin,@KeepID)
                           SELECT SCOPE_IDENTITY()";

            int BookID;
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookName", book.BookName));
                cmd.Parameters.Add(new SqlParameter("@BookClassID", book.BookClassID));
                cmd.Parameters.Add(new SqlParameter("@BookAuthor", book.BookAuthor));
                cmd.Parameters.Add(new SqlParameter("@BookBoughtDate", book.BookBoughtDate));
                cmd.Parameters.Add(new SqlParameter("@BookPublisher", book.BookPublisher));
                cmd.Parameters.Add(new SqlParameter("@BookAmount", book.BookAmount));
                cmd.Parameters.Add(new SqlParameter("@BookNote", book.BookNote));
                cmd.Parameters.Add(new SqlParameter("@KeepID", book.KeeperId ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@CanBeLend", "A"));
                cmd.Parameters.Add(new SqlParameter("@Admin", "Admin"));
                SqlTransaction Tran = conn.BeginTransaction();
                cmd.Transaction = Tran;
                try
                {
                    BookID = Convert.ToInt32(cmd.ExecuteScalar());
                    Tran.Commit();
                }
                catch (Exception)
                {
                    Tran.Rollback();
                    throw;
                }
                finally
                {
                    conn.Close();
                }

            }
            return BookID;
        }


        /// <summary>
        /// Update Book Information
        /// </summary>
        /// <param name="book"></param>
        /// <returns></returns>
        public int UpdateBookInfor(Models.Book book)
        // TODO: lend record need update
        {

            string sql = @"UPDATE BOOK_DATA
                            SET BOOK_NAME = @BookName
                               ,BOOK_CLASS_ID = @BookClassID
                               ,BOOK_AUTHOR = @BookAuthor
                               ,BOOK_BOUGHT_DATE = @BookDate
                               ,BOOK_PUBLISHER = @BookPublisher
                               ,BOOK_NOTE = @BookNote
                               ,BOOK_STATUS = @BookStatus
                               ,BOOK_KEEPER = @BookKeeper
                            WHERE BOOK_ID = @BookId";
            if (book.BookStatus == "B" || book.BookStatus == "C")
            {
                sql += @" 
                        INSERT INTO BOOK_LEND_RECORD
                        (
                            BOOK_ID, KEEPER_ID, LEND_DATE, 
                            CRE_DATE, CRE_USR, MOD_DATE, MOD_USR
                        )
                        VALUES
                        (
                            @BookId, @BookKeeper, GETDATE(),
                            GETDATE(),'Admin', GETDATE(),'Admin'
                        )";
            }

            int result;
            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();
                SqlCommand sqlCommand = new SqlCommand(sql, conn);
                sqlCommand.Parameters.Add(new SqlParameter("@BookId",book.BookID));
                sqlCommand.Parameters.Add(new SqlParameter("@BookName", book.BookName ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookClassID", book.BookClassID ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookAuthor", book.BookAuthor ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookDate", book.BookBoughtDate ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookPublisher", book.BookPublisher ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookNote", book.BookNote ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookStatus", book.BookStatus ?? string.Empty));
                sqlCommand.Parameters.Add(new SqlParameter("@BookKeeper", book.KeeperId ?? string.Empty));
                sqlCommand.Transaction = tran;
                try
                {
                    result = Convert.ToInt32(sqlCommand.ExecuteNonQuery());
                    tran.Commit();
                }
                catch (Exception)
                {
                    tran.Rollback();
                    throw;
                }
                finally
                {
                    conn.Close();
                }

            }
            return result;



        }


        /// <summary>
        ///  Get Book By Condtioin
        /// </summary>
        /// <param name="arg"></param>
        /// <returns></returns>
        public List<Models.Book> GetBookByCondtioin(Models.BookSearchArg arg)
        {
            DataTable dt = new DataTable();
            string sql = @"
                        SELECT 
	                        bd.BOOK_ID AS BookId, bc.BOOK_CLASS_NAME AS BookClassName, bd.BOOK_NAME AS BookName, 
	                        FORMAT(bd.BOOK_BOUGHT_DATE,'yyyy/MM/dd') AS BookBoughtDate, 
	                        bc1.CODE_NAME AS BookStatus,bc1.CODE_ID AS BookStatusCode, mm.USER_ENAME AS KeeperEName,
                            bd.BOOK_KEEPER AS KeeperId
                        FROM BOOK_DATA bd
	                        INNER JOIN BOOK_CLASS bc
	                        ON bd.BOOK_CLASS_ID = bc.BOOK_CLASS_ID
                        LEFT JOIN MEMBER_M mm
	                        ON bd.BOOK_KEEPER = mm.[USER_ID]
                        INNER JOIN BOOK_CODE bc1
	                        ON bd.BOOK_STATUS = bc1.CODE_ID
		                        AND bc1.CODE_TYPE = 'BOOK_STATUS'
                        WHERE
                            (bd.BOOK_ID = @BookId OR @BookId = 0) AND
	                        (bd.BOOK_NAME LIKE ('%' + @BookName + '%') OR @BookName = '') AND
	                        (bd.BOOK_CLASS_ID = @BookClassId OR @BookClassId = '') AND
	                        (bd.BOOK_KEEPER = @KeeperId OR @KeeperId = '') AND
	                        (bd.BOOK_STATUS = @BookStatusCode OR @BookStatusCode = '')
                        ORDER BY 
                            BookBoughtDate DESC";

            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookID", arg.BookId == 0 ? 0 : arg.BookId));
                cmd.Parameters.Add(new SqlParameter("@BookName", arg.BookName ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@BookClassId", arg.BookClassId ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@KeeperId", arg.KeeperId ?? string.Empty));
                cmd.Parameters.Add(new SqlParameter("@BookStatusCode", arg.BookStatusCode ?? string.Empty));
                SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                sqlAdpater.Fill(dt);
                conn.Close();

            }


            return this.MapBookDataToList(dt);
        }

        /// <summary>
        /// 刪除 book
        /// </summary>
        /// <param name="bookId"></param>
        public int DeleteBookById(int bookId)
        {
            try
            {
                // A U 可借出
                string sql = "Delete FROM BOOK_DATA Where BOOK_ID=@BookId AND (BOOK_STATUS ='A'OR BOOK_STATUS ='U')AND BOOK_KEEPER='' ";
                using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.Add(new SqlParameter("@BookId", bookId));
                    var result = cmd.ExecuteNonQuery();
                    conn.Close();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }


        /// <summary>
        /// 根據書本ID拿資料
        /// </summary>
        /// <param name="bookId"></param>
        /// <returns></returns>
        public Models.Book GetBookByID(int bookId)
        {
            DataTable dt = new DataTable();
            string sql = @"
                        SELECT 
	                       bd.BOOK_ID AS BookId, bc.BOOK_CLASS_ID AS BookClassId, bd.BOOK_NAME AS BookName, 
	                       bd.BOOK_AUTHOR AS BookAuthor, bd.BOOK_PUBLISHER AS BookPublisher, bc1.CODE_ID AS BookStatusCode,
                           bd.BOOK_KEEPER AS KeeperId, bd.BOOK_AMOUNT AS BookAmount, bd.BOOK_NOTE AS BookNote, 
                           FORMAT(bd.BOOK_BOUGHT_DATE,'yyyy/MM/dd') AS BookBoughtDate
                        FROM BOOK_DATA bd
	                        INNER JOIN BOOK_CLASS bc
		                        ON bd.BOOK_CLASS_ID = bc.BOOK_CLASS_ID
	                        LEFT JOIN MEMBER_M mm
		                        ON bd.BOOK_KEEPER = mm.[USER_ID]
	                        INNER JOIN BOOK_CODE bc1
		                        ON bd.BOOK_STATUS = bc1.CODE_ID AND bc1.CODE_TYPE = 'BOOK_STATUS'
                        WHERE
                            bd.BOOK_ID = @BookId";

            using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.Add(new SqlParameter("@BookId", bookId));
                SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                sqlAdpater.Fill(dt);
                conn.Close();


            }
            Models.Book result = new Book();
            if (dt.Rows.Count != 0)
            {


                result.BookID = dt.Rows[0]["BookId"].ToString();
                result.BookClassID = dt.Rows[0]["BookClassId"].ToString();
                result.BookName = dt.Rows[0]["BookName"].ToString();
                result.BookAuthor = dt.Rows[0]["BookAuthor"].ToString();
                result.BookPublisher = dt.Rows[0]["BookPublisher"].ToString();
                result.BookStatus = dt.Rows[0]["BookStatusCode"].ToString();
                result.KeeperId = dt.Rows[0]["KeeperId"].ToString();
                result.BookNote = dt.Rows[0]["BookNote"].ToString();
                result.BookBoughtDate = dt.Rows[0]["BookBoughtDate"].ToString();
                result.BookAmount = dt.Rows[0]["BookAmount"].ToString();

            }

            return result;
        }



        /// <summary>
        /// 根據書本ID拿借閱資料
        /// </summary>
        /// <param name="BookId"></param>
        /// <returns></returns>
        public List<BookLend> GetBookLendRecordByBookID(int bookId)
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT
                                    blr.BOOK_ID as BookId
	                               ,FORMAT(blr.LEND_DATE, 'yyyy/MM/dd') AS LendDate
                                   ,mm.USER_ID AS UserId
                                   ,mm.USER_ENAME AS UserEName
                                   ,mm.USER_CNAME AS UserCName
                                FROM BOOK_LEND_RECORD blr
                                LEFT JOIN MEMBER_M mm
	                                ON blr.KEEPER_ID = mm.USER_ID
                                WHERE blr.BOOK_ID = @BookId";
                using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.Add(new SqlParameter("@BookId", bookId));
                    SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                    sqlAdpater.Fill(dt);
                    conn.Close();

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            List<Models.BookLend> result = new List<Models.BookLend>();
            foreach (DataRow row in dt.Rows)
            {
                result.Add(new Models.BookLend()
                {
                    BookID = row["BookId"].ToString(),
                    LendDate = row["LendDate"].ToString(),
                    KeeperId = row["UserId"].ToString(),
                    UserEName = row["UserEName"].ToString(),
                    UserCName = row["UserCName"].ToString()
                });
            }
            return result;

        }


        /// <summary>
        /// Map Book Data To List
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        private List<Models.Book> MapBookDataToList(DataTable dt)
        {
            List<Models.Book> result = new List<Book>();
            foreach (DataRow row in dt.Rows)
            {
                result.Add(new Book()
                {

                    BookID = row["BookId"].ToString(),
                    BookClassName = row["BookClassName"].ToString(),
                    BookName = row["BookName"].ToString(),
                    BookBoughtDate = row["BookBoughtDate"].ToString(),
                    BookStatus = row["BookStatus"].ToString(),
                    BookStatusID = row["BookStatusCode"].ToString(),
                    UserName = row["KeeperEName"].ToString(),
                    KeeperId = row["KeeperId"].ToString()

                });
            }
            return result;
        }

        public List<string> AllBookName()
        {

                DataTable dt = new DataTable();
                try
                {
                    string sql = @"SELECT  bd.BOOK_NAME AS BookName
                                FROM BOOK_DATA bd";
                    ;
                    using (SqlConnection conn = new SqlConnection(this.GetDBConnectionString()))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand(sql, conn);
                        SqlDataAdapter sqlAdpater = new SqlDataAdapter(cmd);
                        sqlAdpater.Fill(dt);
                        conn.Close();

                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }

                List<String> result = new List<String>();
                foreach (DataRow row in dt.Rows)
                {
                    result.Add(row["BookName"].ToString());
                }
                return result;
            }
        
    }
}