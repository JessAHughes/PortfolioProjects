#Cleaning Data in SQL 


SELECT * 
FROM 
  PortfolioProject2.NashvilleHousing;
  
  
#Standardizing the date format


SELECT 
  SaleDate,
  STR_TO_DATE(SaleDate, '%m/%d/%y') AS FormattedDate
FROM 
  PortfolioProject2.NashvilleHousing;
  
  
#Replacing original SaleDate values with yyyy/mm/dd


UPDATE PortfolioProject2.NashvilleHousing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%m/%d/%y %h:%i %p'), '%Y/%m/%d');


#Seperating the PropertyAddress into individual columns (Street_Address, City, State)


SELECT 
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) AS City
FROM 
  PortfolioProject2.NashvilleHousing;

#Adding a new column for Street_Address

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
ADD 
  Street_Address NVARCHAR(255);
  
UPDATE PortfolioProject2.NashvilleHousing
SET Street_Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

#Adding a new column for City

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
ADD 
  City NVARCHAR(255);
  
UPDATE PortfolioProject2.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT OwnerAddress, PropertyAddress
FROM PortfolioProject2.NashvilleHousing;


#Seperating the OwnerAddress into individual columns (OwnerStreetAddress, OwnerCity, OwnerState)


SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1)                              AS OwnerStreetAddress,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)    AS OwnerCity,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)    AS OwnerState
FROM 
  PortfolioProject2.NashvilleHousing;
  
#Adding a new column for OwnerStreetAddress

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
ADD 
  OwnerStreetAddress NVARCHAR(255);
  
UPDATE PortfolioProject2.NashvilleHousing
SET OwnerStreetAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

#Adding a new column for OwnerCity

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
ADD 
  OwnerCity NVARCHAR(255);
  
UPDATE PortfolioProject2.NashvilleHousing
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

#Adding a new column for OwnerState

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
ADD 
  OwnerState NVARCHAR(255);
  
UPDATE PortfolioProject2.NashvilleHousing
SET OwnerState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);


#Change Y and N to Yes and No in SoldAsVacant


SELECT 
  DISTINCT(SoldAsVacant), 
  COUNT(SoldAsVacant)
FROM 
  PortfolioProject2.NashvilleHousing
GROUP BY 
  SoldAsVacant
ORDER BY 2; 

SELECT
  SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM 
  PortfolioProject2.NashvilleHousing;
  
UPDATE PortfolioProject2.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					    WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				        END;


#Removing duplicates


DELETE FROM 
	  PortfolioProject2.NashvilleHousing
WHERE UniqueID IN(
SELECT UniqueID
FROM (
	SELECT *,
	  ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
                   PropertyAddress,
				   SalePrice,
                   SaleDate,
				   LegalReference
                ORDER BY
                   UniqueID
                 ) Row_Num
    FROM 
	  PortfolioProject2.NashvilleHousing
	 ) RowNumCTE
WHERE Row_Num > 1 );


#Deleting the unused columns


SELECT *
FROM 
  PortfolioProject2.NashvilleHousing;
  

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict;

ALTER TABLE 
  PortfolioProject2.NashvilleHousing
DROP COLUMN SaleDate
  